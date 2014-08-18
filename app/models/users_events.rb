class UsersEvents < ActiveRecord::Base
   enum status: [ :not_decided, :attending, :waiting, :attended ]
   validate :event_validation
   validate :duplicate_validation

   belongs_to :event
   belongs_to :user

   after_create :increment_user_count
   after_create :remove_from_waiting_list
   after_destroy :send_email_and_decrease_user_count

  def event_validation
    event = Event.find_by_id(event_id)
    if event.nil?
      errors[:base] << "Event not found"
      if event.attending_user_count.to_i >= event.slot.to_i && self.status == 'attending'
        errors[:base] << "Event is full"
      end
      if event.waiting_user_count.to_i  >= (event.slot.to_i/2 + 1) && self.status == 'waiting'
        errors[:base] << "Waiting list is full"
      end
    end
  end

  def duplicate_validation
    case status
    when 'attending'
      status = 1
    when 'waiting'
      status = 2
    when 'attended'
      status = 3
    end
    users_events = UsersEvents.find_by_user_id_and_event_id_and_status(user_id, event_id, status)
    if users_events.present?
      errors[:base] << "User already #{self.status} this event"
    end
  end

  def remove_from_waiting_list
    if self.attending?
      waiting_list_record = UsersEvents.find_by_event_id_and_user_id_and_status(event_id, user_id, 2)
      waiting_list_record.destroy if waiting_list_record
    end
  end

  def increment_user_count
    if self.attending?
      event.attending_user_count += 1
      event.save
    elsif self.waiting?
      event.waiting_user_count += 1
      event.save
    end
  end

  def send_email_and_decrease_user_count
    if self.attending? && event.slot <= event.attending_user_count
      user_ids = UsersEvents.where('event_id = ? AND status = ?', event_id, 2).map(&:user_id)
      user_ids.each { |wait_user_id| WaitingToAttendEmailWorker::perform_async(wait_user_id, event_id) }
    end

    if self.attending? && event.attending_user_count > 0
      Event.where('id = ?', event_id).update_all('"attending_user_count" = COALESCE("attending_user_count", 1) - 1')
    elsif self.waiting? && event.waiting_user_count > 0
      Event.where('id = ?', event_id).update_all('"waiting_user_count" = COALESCE("waiting_user_count", 1) - 1')
    end
  end

end
