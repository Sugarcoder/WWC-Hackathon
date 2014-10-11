class FinishEvent
  include EventsCategoriesHelper

  def initialize(total_pound, category_pounds, category_ids, attendee_ids)
    @total_pound = total_pound
    @category_pounds = category_pounds
    @category_ids = category_ids
    @attendee_ids = attendee_ids || []
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
    participations = event.users_events

    # Update attendee's user_event_relationship to unfinished if it was set wrong
    finished_user_ids = participations.where(status: 3).map(&:user_id)
    user_ids = finished_user_ids - attendee_ids
    finished_users_events = participations.where('user_id IN (?) AND status = 3', user_ids)
    finished_users_events.update_all("status = 1")

    # Update attendees' user_event_relationship to
    unfinished_users_events = participations.where('user_id IN (?) AND status = 1', attendee_ids)
    p '==============='
    p unfinished_users_events
    unfinished_users_events.update_all("status = 3")
    p '*****************==============='
    p unfinished_users_events
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