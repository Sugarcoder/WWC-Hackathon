class RemindLeaderEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id, event_id, options = {})
    user = User.find_by_id(user_id)
    event = Event.find_by_id(event_id)
    return if user.nil? || event.nil? || event.is_finished
    EventMailer.remind_leader_email(user, event).deliver
    RemindLeaderEmailWorker::perform_at(Time.current + 5.hours, user_id, event.id)
  end
end