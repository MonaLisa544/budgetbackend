class Notification < ApplicationRecord
    belongs_to :user
  
    validates :title, presence: true, length: { maximum: 100 }
    validates :body, length: { maximum: 500 }, allow_blank: true
    validates :notification_type, length: { maximum: 50 }, allow_blank: true
  
    scope :unread, -> { where(read: false) }
    scope :recent, -> { order(created_at: :desc) }
  end
  