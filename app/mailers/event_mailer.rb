class EventMailer < ApplicationMailer
  def new_participant_notification(attendance)
    @attendance = attendance
    @event = attendance.event
    @attendee = attendance.user
    @admin = @event.user
    
    mail(to: @admin.email, subject: "Nouvelle participation à votre événement : #{@event.title}")
  end
end
