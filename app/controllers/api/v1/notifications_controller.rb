class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/notifications
  def index
    notifications = Notification.where(user_id: current_user.id).order(created_at: :desc)
    render json: notifications
  end

  # PATCH /api/v1/notifications/:id/mark_as_read
  def mark_as_read
    notification = Notification.find_by(id: params[:id], user_id: current_user.id)

    if notification
      notification.update(read: true)
      render json: { success: true }
    else
      render json: { error: "Notification not found" }, status: :not_found
    end
  end
end