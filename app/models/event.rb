include EventsHelper

class Event < ActiveRecord::Base
  enum recurring_type: [ :not_recurring, :daily, :every_other_day, :weekly, :monthly ]
  belongs_to :category
  belongs_to :leader, foreign_key: 'leader_id', class_name: 'User'

  validate :event_time_validation

  def starting_date
    return nil if self.starting_time.nil?
    self.starting_time.strftime('%m/%d/%Y') 
  end

  def ending_date
    return nil if self.ending_time.nil?
    self.ending_time.strftime('%m/%d/%Y') 
  end

  def starting_hour
    return nil if self.starting_time.nil?
    self.starting_time.strftime('%l:%M %p')
  end

  def ending_hour
    return nil if self.ending_time.nil?
    self.ending_time.strftime('%l:%M %p')
  end

  def waiting_list_slot
    self.slot.to_i/2 + 1
  end
  
  # different than class method create_recurring_events
  def create_recurring_events(recurring_ending_date, &block)
    return nil if recurring_ending_date.nil? || self.starting_time.nil? || self.ending_time.nil?
    current_date = yield(self.starting_time)
    current_ending_date = yield(self.ending_time)
    while current_date < recurring_ending_date
      event = self.dup
      event.starting_time = current_date
      event.ending_time = current_ending_date
      event.parent_event_id = self.id
      event.attending_user_count = 0
      event.waiting_user_count = 0
      event.pound = 0
      if event.save
      else
        p '------------------------------'
        p event.errors.full_messages
      end
      current_date = yield(current_date)
      current_ending_date = yield(current_ending_date)
    end
  end

  #####################################################################
  # Validation
  #####################################################################

  def event_time_validation
    if self.starting_time < 2.minutes.ago
      errors[:base] << "Event starting time can not be older than current time"
    end

    if self.starting_time > self.ending_time
      errors[:base] << "starting time can not after ending time"
    end
  end
  

  class << self

    def create_recurring_events(recurring_event_type, recurring_ending_date, event)
        return if recurring_event_type == 'not_recurring' || event.nil? || recurring_ending_date.nil? #no recurring event
        recurring_ending_date = self.parse_event_date(recurring_ending_date, '12:00 PM')
        case recurring_event_type
        when 'daily'
          event.create_recurring_events(recurring_ending_date, &self.adding_day)
        when 'weekly'
          event.create_recurring_events(recurring_ending_date, &self.adding_week)
        when 'monthly'
          event.create_recurring_events(recurring_ending_date, &self.adding_month)
        end
    end

    def parse_event_date(date_string, time_string)
      str = date_string + ' ' + time_string
      date = Date._strptime(str, '%m/%d/%Y %I:%M %p')
      DateTime.new(date[:year], date[:mon], date[:mday], date[:hour], date[:min], 0)
    end

    def adding_month
      lambda { |time| time.next_month }
    end

    def adding_week
      lambda { |time| time + 7.days }
    end

    def adding_day
      lambda { |time| time.tomorrow }
    end

  end

end
