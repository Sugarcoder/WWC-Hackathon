class AttendRecurringEvent

  def initialize(starting_time, ending_time, weekly_count, weekdays)
    @starting_time = starting_time
    @ending_time = ending_time
    @weekly_count = weekly_count
    @weekdays = weekdays
  end

  def run(user, event)
    return { error: true, message: 'Event not found'} unless event.present?
    return { error: true, message: 'User not found'} unless user.present?
    return { error: true, message: "You need to specify on which day you want to attend the event"} if event.daily? && @weekdays.nil?
    return { error: true, message: "Ending date when to stop attend this evnet is required."} unless @ending_time.present?

    main_recurring_event_id = event.main_recurring_event_id
    summary = attend_recurring_summary(@weekly_count, @weekdays)

    events = Event.select( :id, :starting_time ).within_time_range( @starting_time, @ending_time ).where( 'parent_event_id = ? and extract(DOW FROM starting_time) IN (?) ', main_recurring_event_id, @weekdays ).group_by { |event| event.starting_time.wday }
    event_ids = select_events_by_weekly_count( events, @weekly_count ).map(&:id) + [ event.id ]
    
    users_events_params = event_ids.uniq.map{ |event_id| { event_id: event_id, status: 1, user_id: user.id, parent_id: main_recurring_event_id, summary: summary } }
    UsersEvents.create(users_events_params)

    send_attend_recurring_email(user, event)

    return { error: false, message: summary }
  end

  private

  def select_events_by_weekly_count(events, weekly_count)
    result = []
    case weekly_count
    when 1
      events.each do |weekday, events_of_weekday|
        events_of_weekday.each_with_index{ |event, index| result << event }
      end
    when 2
      events.each do | weekday, events_of_weekday |
        events_of_weekday.each_with_index do  { |event, index| result << event if index.even? }
      end
    when 3
      events.each do | weekday, events_of_weekday |
        events_of_weekday.each_with_index{ |event, index| result << event if index % 3 == 0 }
      end
    end
    result
  end

  def attend_recurring_summary(weekly_count, weekdays)
    summary = "attend "
    summary += case weekly_count
              when 1
                'weekly'
              when 2
                'biweekly'
              when 3
                'triweekly'
              end
    summary += " on "
    weekdays_str = weekdays.map{ |weekday| Date::DAYNAMES[weekday] }.join(', ')
    summary += weekdays_str
  end

  def send_attend_recurring_email(user, event)
    AttendEmailWorker::perform_async(user.id, event.id)
  end

end