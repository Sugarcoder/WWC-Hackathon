class CancelEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id, event_id, options = {})
    user = User.find_by_id(user_id)
    event =  Event.includes(:location).find_by_id(event_id)
    return if user.nil? || event.nil?
    EventMailer.cancel_email(user, event).deliver
  end

end