include EventsHelper

class Event < ActiveRecord::Base
  acts_as_commentable
  
  enum recurring_type: [ :not_recurring, :daily, :every_other_day, :weekly, :monthly ]
  belongs_to :category
  belongs_to :location
  belongs_to :leader, foreign_key: 'leader_id', class_name: 'User'
  has_many :images, -> { where('is_receipt is not true') }
  has_one :receipt, -> { where('is_receipt is true') }, foreign_key: 'event_id', class_name: 'Image'
  validate :starting_time_after_current_time, on: :create
  validate :starting_time_before_ending_time
  validate :finish_process, on: :update, if: Proc.new { |event| event.is_finished == true }
  
  validates :ending_time, presence: true
  validates :starting_time, presence: true
  validates :title, presence: true
  validates :slot,  presence: true

  after_commit :after_create_action, on: :create

  has_attached_file :instruction, styles: {thumbnail: "60x60#"}
  validates_attachment :instruction, content_type: { content_type: "application/pdf" }

  def after_create_action
    send_email
    sign_up_lead_rescuer
  end

  def sign_up_lead_rescuer
    UsersEvents.create(user_id: leader_id, event_id: id, status: 1)
  end

  def send_email
    #send attendence email to lead rescuer 3 hours before event beginning. if starting time is less than 3 hours from creating time, send it directly.
    if starting_time < Time.current + 180.minutes
      LeaderAttendEmailWorker::perform_async(leader_id, id)
    else
      LeaderAttendEmailWorker::perform_at(starting_time - 179.minutes, leader_id, id)
    end
    # send remind leader email after events ends.
    RemindLeaderEmailWorker::perform_at(ending_time, leader_id, id)
  end
  
  def starting_date
    self.starting_time.strftime(date_with_hour) unless self.starting_time.nil?
  end

  def ending_date
    self.ending_time.strftime(date_with_hour) unless self.ending_time.nil?
  end

  def starting_hour
    self.starting_time.strftime(hour) unless self.starting_time.nil?
  end

  def ending_hour
    self.ending_time.strftime(hour) unless self.ending_time.nil?
  end

  def starting_date_with_full_weekday_name
    self.starting_time.strftime(date_with_full_weekday_name) unless self.starting_time.nil?
  end

  def ending_date_with_full_weekday_name
    self.ending_time.strftime(date_with_full_weekday_name) unless self.ending_time.nil?
  end

  def date_with_hour
    # 08/05/2014  2:00 PM
    '%m/%d/%Y %l:%M %p'
  end

  def hour
    # 2:00 PM
    '%l:%M %p'
  end

  def date_with_full_weekday_name
    #  Wednesday, August 27, 2014
    '%A, %B %e, %Y'
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

  def user_status_editable?
    self.starting_time > Time.current
  end

  def full?
    slot = self.slot || 0
    slot <= self.attending_user_count
  end

  #####################################################################
  # Validation
  #####################################################################
  def starting_time_after_current_time
    if self.starting_time && self.starting_time < 2.minutes.ago
      errors[:base] << "Event starting time can not be older than current time"
    end
  end

  def starting_time_before_ending_time
    return if self.starting_time.nil? || self.ending_time.nil?
    if self.starting_time > self.ending_time
      errors[:base] << "starting time can not after ending time"
    end
  end

  def finish_process
    errors[:base] << "pound is required!" if pound.nil?
    if pound != 0 && self.receipt.nil?
      errors[:base] << "receipt is required!"
    end
  end
  

  class << self

    def create_recurring_events(recurring_event_type, recurring_ending_date, event)
        return if recurring_event_type == 'not_recurring' || event.nil? || !recurring_ending_date.present? #no recurring event
        recurring_ending_date = self.parse_event_date(recurring_ending_date)
        case recurring_event_type
        when 'daily'
          event.create_recurring_events(recurring_ending_date, &self.adding_day)
        when 'weekly'
          event.create_recurring_events(recurring_ending_date, &self.adding_week)
        when 'monthly'
          event.create_recurring_events(recurring_ending_date, &self.adding_month)
        end
    end

    def parse_event_date(time_string)
      date = Date._strptime(time_string, '%m/%d/%Y %I:%M %p')
      Time.zone.local(date[:year], date[:mon], date[:mday], date[:hour], date[:min], 0)
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

    def attend_recurring_summary( weekly_count, dates)
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
      dates.each do |date| 
        summary += date == dates.last ? Date::DAYNAMES[date.wday] : Date::DAYNAMES[date.wday] + ", " 
      end
      summary
    end

  end

end
