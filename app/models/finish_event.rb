class FinishEvent

  def initialize(total_pound, category_pounds, category_ids, attendee_ids)
    @total_pound = total_pound
    @category_pounds = category_pounds
    @category_ids = category_ids
    @attendee_ids = attendee_ids
  end

  def run(event)
    return  { error: true, message: 'Event not found' } if event.nil?

    if event.is_finished 
      { error: true, message: 'The event is already finished' }
    else
      if event.update_attributes(is_finished: true, pound: @total_pound )
        send_thank_you_email(@attendee_ids, event)
        record_pounds_for_each_category(@category_pounds, @category_ids, event)
        { error: false, message: 'You successfully finished the event! thank you' }
      else
        { error: true, message: event.errors.full_messages.join(", ") }
      end
    end
  end

  def extract_array_params(array)
    array = array.map(&:to_i)
    array.pop
    array
  end

  def create_event_categories_params(category_pounds, category_ids, event_id)
    category_pounds_and_ids = category_pounds.zip(category_ids).delete_if{ |array| array[0] == 0 || array[1] == 0 }
    category_pounds_and_ids.map{ |array| { pound: array[0], category_id: array[1], event_id: event_id } }
  end

  def record_pounds_for_each_category(category_pounds, category_ids, event)
    category_pounds = extract_array_params(category_pounds)
    category_ids = extract_array_params(category_ids)
    event_category_params = create_event_categories_params(category_pounds, category_ids, event.id)
    EventsCategories.create(event_category_params)
  end

  def send_thank_you_email(attendee_ids, event)
    # Update attendees' user_event_relationship to finished
    UsersEvents.where('user_id IN (?) AND event_id = ?', attendee_ids, event.id).update_all("status = 3")
    # send email
    attendee_ids.each do |user_id|
      ThankEmailWorker::perform_async(user_id, event.id)
    end if attendee_ids
  end

end