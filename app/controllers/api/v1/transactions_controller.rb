class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]

  def index
    @transactions = Transaction.includes(:category)
                                .filter_by_date(params[:start_date], params[:end_date], current_user.id)
                                .order(created_at: :desc)
  
    render json: TransactionSerializer.new(@transactions).serialized_json
  end
  

  def show
    render json: TransactionSerializer.new(@transaction).serialized_json
  end

  def create
    wallet_type = params[:transaction][:wallet_type] # гаднаас ирж байгаа параметр
    transaction_data = transaction_params
  
    wallet = case wallet_type
             when "family"
               Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id)
             when "private"
               current_user.wallet
             else
               nil
             end
  
    return render json: { error: "Wallet олдсонгүй" }, status: :not_found unless wallet
    return render json: { error: "Энэ wallet дээр transaction хийх эрхгүй байна" }, status: :forbidden unless authorized_to_create?(wallet.id)
  
    @transaction = current_user.transactions.build(transaction_data.merge(wallet_id: wallet.id))
  
    if @transaction.save
      # 🔥 Transaction амжилттай хадгалагдлаа, одоо Budget update хийнэ
      budget = Budget.where(
        category_id: @transaction.category_id,
        wallet_id: @transaction.wallet_id
      ).where("start_date <= ? AND due_date >= ?", @transaction.transaction_date, @transaction.transaction_date).first
  
      if budget.present?
        budget.used_amount += @transaction.transaction_amount
        budget.save!
      end
  
      render json: TransactionSerializer.new(@transaction).serialized_json, status: :created
    else
      render json: { errors: format_errors(@transaction.errors) }, status: 422
    end
  end
  
  def update
    return render json: { error: "Энэ transaction-г өөрчлөх эрхгүй байна" }, status: :forbidden unless authorized_to_edit?(@transaction)

    Transaction.transaction do
      attributes = transaction_params.to_h.symbolize_keys

      if attributes[:category_id].present?
        category = Category.find_by(id: attributes[:category_id], user_id: current_user.id, delete_flag: false)
        if category.nil?
          render json: { errors: "Invalid category_id" }, status: 422 and return
        end
      end

      @transaction.update!(attributes)
      @transaction.delete_associated_recurring_transactions if @transaction.frequency.nil?
    end

    render json: TransactionSerializer.new(@transaction).serialized_json
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: format_errors(e.record.errors) }, status: 422
  rescue => e
    render json: { error: e.message }, status: 400
  end

  def destroy
    return render json: { error: "Энэ transaction-г устгах эрхгүй байна" }, status: :forbidden unless authorized_to_edit?(@transaction)

    Transaction.transaction do
      if @transaction.frequency
        @transaction.delete_associated_recurring_transactions
      end
      @transaction.update!(delete_flag: true)
    end

    render json: TransactionSerializer.new(@transaction).serialized_json
  rescue => e
    render json: { error: e.message }, status: 400
  end

  def total_transactions
    categories = Category.select(:id, :category_name, :transaction_type, :icon)
                         .where(delete_flag: false, user_id: current_user.id)
                         .tap do |c|
                           c.where!(id: params[:category_id]) if params[:category_id].present?
                           c.where!(transaction_type: params[:type]) if params[:type].present?
                         end

    filtered_transactions = Transaction.where(delete_flag: false)
    if params[:start_date].present? || params[:end_date].present?
      filtered_transactions = filtered_transactions.where(transaction_date: params[:start_date]..params[:end_date])
    end

    formatted_data = categories.map do |category|
      category_transactions = filtered_transactions.where(category_id: category.id)
      {
        id: category.id,
        category_name: category.category_name,
        icon: category.icon,
        transaction_type: category.transaction_type,
        amount: category_transactions.sum('transaction_amount') || 0,
        transactions_count: category_transactions.count || 0
      }
    end

    formatted_data.group_by { |data| data[:transaction_type] }
                  .transform_values do |categories|
      {
        total: categories.sum { |category| category[:amount] },
        categories: categories.map { |category| category.except(:transaction_type) }
      }
    end

    render json: { data: formatted_data }, status: 200
  end

  def category_transactions
    category = Category.find_by(id: params[:category_id])
    raise ActiveRecord::RecordNotFound, 'Category not found' unless category

    transactions = Transaction.where(category_id: params[:category_id])
                              .filter_by_date(params[:start_date], params[:end_date], current_user.id)
    render json: TransactionSerializer.new(transactions).serialized_json, status: 200
  end

  private

  def format_errors(errors)
    errors.messages.transform_keys(&:to_s).transform_values { |msgs| msgs.join(', ') }
  end

  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date, :description, :category_id)
  end

  def set_transaction
    @transaction = Transaction.find_by(id: params[:id], user_id: current_user.id, delete_flag: false)
    render json: { error: 'Transaction not found' } unless @transaction
  end

  # --- Permission methods ---

  def authorized_to_create?(wallet_id)
    wallet = Wallet.find_by(id: wallet_id)
    return false unless wallet

    case wallet.owner_type
    when "User"
      wallet.owner_id == current_user.id
    when "Family"
      current_user.family_id == wallet.owner_id && current_user.admin?
    else
      false
    end
  end

  def authorized_to_view?(transaction)
    wallet = transaction.wallet
    case wallet.owner_type
    when "User"
      wallet.owner_id == current_user.id
    when "Family"
      current_user.family_id == wallet.owner_id
    else
      false
    end
  end

  def authorized_to_edit?(transaction)
    wallet = transaction.wallet
    case wallet.owner_type
    when "User"
      wallet.owner_id == current_user.id
    when "Family"
      current_user.family_id == wallet.owner_id && current_user.admin?
    else
      false
    end
  end
end
