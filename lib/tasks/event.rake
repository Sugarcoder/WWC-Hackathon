namespace :event do
  
=begin
  desc "extend weekly events of yesterday"
  task weekly_extend: :environment do
    weekly_events = Event.where('starting_time < ? and recurring_type = ?', Date.today.beginning_of_day, 3)
    weekly_events.each do |event|
      event.starting_time = event.starting_time + 7.days if event.starting_time
      event.ending_time = event.ending_time + 7.days if event.ending_time
      event.save
    end if weekly_events.present?
  end

  desc "extend monthly events of yesterday"
  task monthly_extend: :environment do
    monthly_events = Event.where('starting_time < ? and recurring_type = ?', Date.today.beginning_of_day, 4)
    monthly_events.each do |event|
      event.starting_time = event.starting_time.next_month if event.starting_time
      event.ending_time = event.ending_time.next_month if event.ending_time
      event.save
    end if monthly_events.present?
  end

  desc "extend daily events of yesterday"
  task daily_extend: :environment do
    daily_events = Event.where('starting_time < ? and recurring_type = ?', Date.today.beginning_of_day, 1)
    daily_events.each do |event|
      event.starting_time = event.starting_time.tomorrow if event.starting_time
      event.ending_time = event.ending_time.tomorrow if event.ending_time
      event.save
    end if daily_events.present?
  end

  desc "extend daily events of yesterday"
  task every_other_day_extend: :environment do
    daily_events = Event.where('starting_time < ? and recurring_type = ?', Date.today.beginning_of_day, 2)
    daily_events.each do |event|
      event.starting_time = event.starting_time.tomorrow.tomorrow if event.starting_time
      event.ending_time = event.ending_time.tomorrow.tomorrow if event.ending_time
      event.save
    end if daily_events.present?
  end
=end

end
