class Api::V1::NotificationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_notification, only: [:show, :update, :destroy]
  
    # GET /api/v1/notifications
    def index
      begin
        @notifications = Notification.where(user_id: current_user.id, read: false)
  
        if @notifications.present?
          render json: NotificationSerializer.new(@notifications).serialized_json
        else
          raise ActiveRecord::RecordNotFound, 'Notifications not found'
        end
      rescue ActiveRecord::RecordNotFound => exception
        render json: { errors: { name: [exception.message] } }, status: :not_found
      end
    end
  
    # GET /api/v1/notifications/:id
    def show
      render json: NotificationSerializer.new(@notification).serialized_json
    end
  
    # POST /api/v1/notifications
    def create
      begin
        @notification = current_user.notifications.build(notification_params)
        @notification.save!
        render json: NotificationSerializer.new(@notification).serialized_json, status: :created
      rescue ActionController::ParameterMissing => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors }, status: :unprocessable_entity
      end
    end
  
    # PUT /api/v1/notifications/:id
    def update
      if @notification.update(notification_params)
        render json: NotificationSerializer.new(@notification).serialized_json, status: :ok
      else
        render json: { errors: @notification.errors }, status: :unprocessable_entity
      end
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      handle_record_invalid(e)
    end
  
    # DELETE /api/v1/notifications/:id
    def destroy
      @notification.update(delete_flag: true)
      render json: { message: 'Notification successfully deleted' }, status: :ok
    end
  
    private
  
    def notification_params
      params.require(:notification).permit(:title, :body, :notification_type, :read, :user_id)
    end
  
    def set_notification
      begin
        @notification = Notification.find_by(user_id: current_user.id, id: params[:id], delete_flag: false)
  
        unless @notification
          raise ActiveRecord::RecordNotFound, 'Notification not found'
        end
      rescue ActiveRecord::RecordNotFound => exception
        render json: { errors: { name: [exception.message] } }, status: :not_found
      end
    end
  end
  