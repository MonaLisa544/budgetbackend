class Api::V1::WalletsController < ApplicationController
  before_action :authenticate_user!

  # ① GET /wallets/me
  def me
    wallet = current_user.wallet
    render json: WalletSerializer.new(wallet).serialized_json
  end

  # ② GET /wallets/family
  def family
    return render json: { error: "Not in a family" }, status: :forbidden unless current_user.family_id

    wallet = Wallet.find_by(owner_type: 'Family', owner_id: current_user.family_id)
    return render json: { error: "Family wallet not found" }, status: :not_found unless wallet

    render json: WalletSerializer.new(wallet).serialized_json
  end

  # ③ PUT /wallets/me
  def update_me
    wallet = current_user.wallet
    wallet.update(balance: params[:balance].to_f)
    render json: WalletSerializer.new(wallet).serialized_json
  end

  # ④ PUT /wallets/family
  def update_family
    return render json: { error: "Not in a family" }, status: :forbidden unless current_user.family_id
    return render json: { error: "You don't have permission" }, status: :forbidden unless current_user.admin?

    wallet = Wallet.find_by(owner_type: 'Family', owner_id: current_user.family_id)
    return render json: { error: "Family wallet not found" }, status: :not_found unless wallet

    wallet.update(balance: params[:balance].to_f)
    render json: WalletSerializer.new(wallet).serialized_json
  end
end
