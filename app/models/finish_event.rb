class FinishEvent
  include EventsCategoriesHelper

  def initialize(total_pound, category_pounds, category_ids, attendee_ids)
    @total_pound = total_pound
    @category_pounds = category_pounds
    @category_ids = category_ids
    @attendee_ids = attendee_ids
  end

  def run(event)
    return  { error: true, message: 'Event not found' } if event.nil?
    return  { error: true, message: 'The event is already finished' } if event.is_finished 
    
    if event.update_attributes(is_finished: true, pound: @total_pound )
      confirm_user_attendence(@attendee_ids, event)
      record_pounds_for_each_category(@category_pounds, @category_ids, event)
      { error: false, message: 'You successfully finished the event! thank you' }
    else
      { error: true, message: event.errors.full_messages.join(", ") }
    end
  end

  def update(event)
    return  { error: true, message: 'Event not found' } if event.nil?
    
    confirm_user_attendence(@attendee_ids, event)

    event.update_attribute(:pound, @total_pound)

    event.events_categories.destroy_all
    record_pounds_for_each_category(@category_pounds, @category_ids, event)
  end

  def confirm_user_attendence(attendee_ids, event)
    # Update attendees' user_event_relationship to finished
    unfinished_users_events =  UsersEvents.where('user_id IN (?) AND event_id = ? AND status != 3', attendee_ids, event.id)
    unfinished_users_events.update_all("status = 3")

    unfinished_user_ids = unfinished_users_events.map(&:user_id)
    send_thank_you_email(unfinished_user_ids, event)
  end

  private

  def send_thank_you_email(attendee_ids, event)
    attendee_ids.each do |user_id|
      ThankEmailWorker::perform_async(user_id, event.id)
    end if attendee_ids
  end

end