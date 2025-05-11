class Api::V1::LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan, only: [:show, :update, :destroy]

  # GET /api/v1/loans
  def index
    if current_user.role == 1 && current_user.family_id.present?
      wallet_ids = Wallet.where(owner_type: ['User', 'Family'], owner_id: [current_user.id, current_user.family_id]).pluck(:id)
    else
      wallet_ids = [current_user.wallet.id]
    end

    loans = Loan.where(wallet_id: wallet_ids)
    render json: LoanSerializer.new(loans).serializable_hash.to_json
  end

  # GET /api/v1/loans/:id
  def show
    render json: LoanSerializer.new(@loan).serializable_hash.to_json
  end

  # POST /api/v1/loans
  def create
    loan_data = loan_params.except(:type)

    wallet =
      if params[:loan][:type] == "family"
        if current_user.family_id && current_user.admin?
          Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id)
        else
          return render json: { error: "No permission to use family wallet" }, status: :forbidden
        end
      else
        current_user.wallet
      end

    return render json: { error: "Wallet not found" }, status: :not_found unless wallet

    loan = Loan.new(loan_data.merge(wallet_id: wallet.id))

    if loan.save
      render json: LoanSerializer.new(loan).serializable_hash.to_json, status: :created
    else
      render json: { errors: loan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/loans/:id
  def update
    unless authorized_to_edit?(@loan)
      return render json: { error: "No permission to update" }, status: :forbidden
    end

    if @loan.update(loan_params)
      render json: LoanSerializer.new(@loan).serializable_hash.to_json
    else
      render json: { errors: @loan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/loans/:id
  def destroy
    unless authorized_to_edit?(@loan)
      return render json: { error: "No permission to delete" }, status: :forbidden
    end

    @loan.destroy
    head :no_content
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])

    unless authorized_to_view?(@loan)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def loan_params
    params.require(:loan).permit(
      :wallet_id,
      :loan_name,
      :loan_type,
      :original_amount,
      :interest_rate,
      :monthly_payment_amount,
      :monthly_due_day,
      :start_date,
      :due_date,
      :status,
      :description
    )
  end

  def authorized_to_view?(loan)
    owner = loan.wallet.owner

    case loan.wallet.owner_type
    when "User"
      owner.id == current_user.id
    when "Family"
      current_user.family_id == owner.id
    else
      false
    end
  end

  def authorized_to_edit?(loan)
    owner = loan.wallet.owner

    case loan.wallet.owner_type
    when "User"
      owner.id == current_user.id
    when "Family"
      current_user.family_id == owner.id && current_user.admin?
    else
      false
    end
  end
end
