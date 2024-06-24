class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]

  include TransactionsHelper

  def index
    transactions = Transaction.filter_by_date(params[:start_date], params[:end_date], current_user.id)
                              .paginate(page: page, per_page: per_page)
    render json: TransactionSerializer.new(transactions).serialized_json, status: 200
  end

  def show
    render json: TransactionSerializer.new(@transaction).serialized_json
  end

  def create
    process_transaction(@transaction, 'create')
  end

  def update
    process_transaction(@transaction, 'update')
  end

  def destroy
    process_transaction(@transaction, 'destroy')
  end

  # get all transactions grouped by transaction type & category
  def total_transactions
    formatted_data = aggregate_transactions
    render json: { data: formatted_data }, status: 200
  end

  # get only selected category's transactions
  def category_transactions
    transactions = Transaction.where(category_id: params[:category_id])
                                      .filter_by_date(params[:start_date], params[:end_date],current_user.id)
    render json: TransactionSerializer.new(transactions).serialized_json, status: 200
  end

  private

  def set_transaction
    @transaction = Transaction.find_by(id: params[:id], user_id: current_user.id, delete_flag: false)
    render_not_found if @transaction.nil?
    rescue => e
        render json: { error: e.message }, status: 400
    end
end
