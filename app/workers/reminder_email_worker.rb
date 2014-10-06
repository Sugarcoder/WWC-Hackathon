class ReminderEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id, event_id, options = {})
    user = User.find_by_id(user_id)
    event =  Event.includes(:location).find_by_id(event_id)
    return if user.nil? || event.nil?
    event_leader = event.leader
    users_events = UsersEvents.find_by_user_id_and_event_id(user.id, event.id)
    return if event_leader.nil? || users_events.nil? || !users_events.attending?
    EventMailer.reminder_email(user, event, event_leader).deliver
  end

end