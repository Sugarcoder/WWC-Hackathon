class AttendEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id, event_id, options = {})
    user = User.find_by_id(user_id)
    event = Event.includes(:location).find_by_id(event_id)
    return if user.nil? || event.nil?
    
    event_leader = event.leader 
    user_event_relationship = UsersEvents.find_by_user_id_and_event_id(user.id, event.id)
    return if event_leader.nil? || user_event_relationship.nil?
    
    summary = user_event_relationship.summary
    EventMailer.attend_email(user, event, event_leader, summary).deliver
  end
end