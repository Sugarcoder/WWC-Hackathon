class LeaderAttendEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id, event_id, options={})
    user = User.find_by_id(user_id)
    event =  Event.includes(:location).find_by_id(event_id)
    return if user.nil? || event.nil?
    user_ids = UsersEvents.where("event_id = ? and status = ?", event_id, 1).map(&:user_id)
    attend_user_list = User.where('id IN (?)', user_ids)
    EventMailer.leader_attend_email(user, event, attend_user_list).deliver
  end


end