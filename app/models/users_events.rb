class UsersEvents < ActiveRecord::Base
   enum status: [ :not_decided, :attending, :waiting, :attended ]
   validate :event_validation
   validate :duplicate_validation
   validate :can_attend?, on: :create

   belongs_to :event
   belongs_to :user

   after_create :after_create_action
   after_destroy :send_email_and_decrease_user_count

  def event_validation
    event = Event.find_by_id(event_id)
    if event.nil?
      errors[:base] << "Event not found"
    else
      if event.full? && self.status == 'attending'
        errors[:base] << "Event is full"
      end
      if event.wait_list_full? && self.status == 'waiting'
        errors[:base] << "Waiting list is full"
      end
    end
  end

  def can_attend?
    can_change_participation_status?('attend')
  end

  def can_cancel?
    can_change_participation_status?('cancel')
    errors.blank?
  end

  def can_change_participation_status?(action)
    if Time.now + 3.hours > event.starting_time && attending?
      errors[:base] << "Sorry, you can only #{action} an event up to 3 hours before the event starts."
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

  def after_create_action
    increment_user_count
    send_email_after_sign_up_event
    remove_from_waiting_list
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

  def send_email_after_sign_up_event
    if self.attending?
      # attend event confirmation email
      AttendEmailWorker::perform_async(user_id, event_id) unless parent_id.present? 
      if Time.current < event.starting_time - 24.hour # attending time is 1 day earlier than event starting time
        # reminder email
        ReminderEmailWorker::perform_at(event.starting_time - 24.hour, user_id, event_id)
        if Time.current < event.starting_time - 7.days  # send reminder email before 1 week
          ReminderEmailWorker::perform_at(event.starting_time - 7.days, user_id, event_id)
        end 
      end
    elsif self.waiting?
      WaitingListEmailWorker::perform_async(user_id, event_id)
    end 
  end

  def send_email_and_decrease_user_count
    # send cancel email to current user
    CancelEmailWorker::perform_async(user_id, event_id) unless parent_id.present? 

    # send notice email to user who is waiting for the event when event is full
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

  def attend_recurring?
    self.attending? && self.parent_id != nil
  end

end
