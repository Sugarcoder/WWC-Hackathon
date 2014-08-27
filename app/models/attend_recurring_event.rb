class AttendRecurringEvent

  def initialize(starting_time, ending_time, weekly_count, weekdays)
    @starting_time = starting_time
    @ending_time = ending_time
    @weekly_count = weekly_count
    @weekdays = weekdays
  end

  def run(user, event)
    dates = select_possible_recurring_event_time(@starting_time, @ending_time, @weekdays)
    event_time_array = select_recurring_event_time_with_weekly_count(dates, @weekly_count)
    main_recurring_event_id = event.main_recurring_event_id
    summary = attend_recurring_summary(@weekly_count, @weekdays)

    event_ids = Event.select(:id).where('parent_event_id = ? and starting_time IN (?)', main_recurring_event_id, event_time_array).map(&:id) + [event.id]
    users_events_params = event_ids.uniq.map{ |event_id| { event_id: event_id, status: 1, user_id: user.id, parent_id: main_recurring_event_id, summary: summary } }

    UsersEvents.create(users_events_params)

    summary
  end

  private

  def select_possible_recurring_event_time(starting_time, ending_time, weekdays)
    dates = (starting_time.to_date..ending_time.to_date).to_a.select {|k| weekdays.include?(k.wday)}
    dates.map! do |date|
      event_time = Time.zone.local(date.year, date.month, date.day)
      event_time += starting_time.seconds_since_midnight.seconds
    end if dates
    dates
  end

  def select_recurring_event_time_with_weekly_count(dates, weekly_count)
    result = []
    case weekly_count
    when 1
      result = dates
    when 2
      dates.each_with_index{ |date, index| result << date if index.even? }
    when 3
      dates.each_with_index { |date, index| result << date if index % 3 == 0 }
    end
    result
  end

  def attend_recurring_summary( weekly_count, weekdays)
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

end