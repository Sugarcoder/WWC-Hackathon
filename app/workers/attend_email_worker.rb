class AttendEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id, event_id, options = {})
    user = User.find_by_id(user_id)
    event = Event.find_by_id(event_id)
    event_leader = event.leader if event
    return if user.nil? || event.nil? || event_leader.nil?
    EventMailer.attend_email(user, event, event_leader).deliver
  end
end