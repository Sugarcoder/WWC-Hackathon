class CreateUserReport

  def initialize(role)
    @role = role
  end

  def run
    case @role
    when "normal"
      report_for_normal_users
    when "admin"
    end
  end

  def report_for_normal_users
    users = User.all.order('id ASC')
    result = []
    user_ids_who_missed_event = user_ids_of_missed_events
    users.each do |user|
      user_hash = {}
      user_hash[:id] = user.id
      user_hash[:name] = user.full_name
      user_hash[:email] = user.email
      user_hash[:attened_event_count] = UsersEvents.where('user_id = ? AND status = ?', user.id, 3).count
      user_hash[:missed_event_count] = user_ids_who_missed_event.count(user.id)
      result << user_hash
    end
    result
  end

  def user_ids_of_missed_events
    UsersEvents.joins(:event).where('status = 1 AND is_finished is true').pluck(:user_id)
  end
end
