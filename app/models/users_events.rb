class UsersEvents < ActiveRecord::Base
   enum status: [ :not_decided, :attending, :waiting, :attended ]
   validate :event_validation
   validate :duplicate_validation

   belongs_to :event
   belongs_to :user

   after_create :increment_attending_user_count
   after_destroy :decrease_attending_user_count

  def event_validation
    event = Event.find_by_id(event_id)
    if event.nil?
      errors[:base] << "Event not found"
      if event.attending_user_count.to_i >= event.slot.to_i && self.status == 'attending'
        errors[:base] << "Event is full"
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

  def increment_attending_user_count
    if self.status == 'attending' 
      event.attending_user_count += 1
      event.save
    end
  end

  def decrease_attending_user_count
    if self.status == 'attending' && event.attending_user_count > 0
      event.attending_user_count -= 1
      event.save
    end
  end
end
