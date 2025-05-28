class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :event
  
  validates :user_id, uniqueness: { scope: :event_id, message: "You have already registered for this event" }

  after_create :send_notification_to_event_admin
  
  private
  def send_notification_to_event_admin
    EventMailer.new_participant_notification(self).deliver_now
  end
end
