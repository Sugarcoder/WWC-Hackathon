include EventsHelper

class Event < ActiveRecord::Base
  enum recurring_type: [ :not_recurring, :daily, :weekly, :monthly ]

  belongs_to :category
  belongs_to :location
  belongs_to :instruction
  belongs_to :leader, foreign_key: 'leader_id', class_name: 'User'
  has_many :images, -> { where.not(is_receipt: true) }, dependent: :destroy
  has_many :events_categories, foreign_key: 'event_id', class_name: "EventsCategories", dependent: :destroy
  has_many :users_events, foreign_key: 'event_id', class_name: "UsersEvents", dependent: :destroy
  has_many :attendees, through: :users_events, source: :user
  has_one :receipt, -> { where(is_receipt: true) }, foreign_key: 'event_id', class_name: 'Image', dependent: :destroy

  scope :within_time_range, ->(starting_time, ending_time) { where('starting_time >= ? AND ending_time <= ?', starting_time, ending_time).order('starting_time ASC') }
  scope :start_after,  ->(time) { where('starting_time > ?', time) }
  scope :start_before, ->(time) { where('starting_time < ?', time) }
  scope :end_before,   ->(time) { where('ending_time < ?', time) }
  scope :finished,     ->       { where(is_finished: true) }
  scope :not_finished, ->       { where.not(is_finished: true) }
  scope :with_leader,  ->(leader_id) { where('leader_id = ?', leader_id) }

  after_commit :after_create_action, on: :create
  before_update :change_leader
  after_destroy :destroy_comments

  validate :starting_time_after_current_time, on: :create
  validate :starting_time_before_ending_time
  validate :finish_process, on: :update, if: Proc.new { |event| event.is_finished == true }
  validate :leader_validation

  validates :ending_time, presence: true
  validates :starting_time, presence: true
  validates :title, presence: true
  validates :slot,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :leader_id,  presence: true

  delegate :name, to: :location, prefix: true, allow_nil: true
  delegate :full_name, :email, to: :leader, prefix: true, allow_nil: true

  acts_as_commentable #could adding comment to it


  def after_create_action
    sign_up_lead_rescuer
    send_email_to_lead_rescuer
  end

  def destroy_comments
    self.comment_threads.destroy_all
  end

  def sign_up_lead_rescuer
    UsersEvents.create(user_id: leader_id, event_id: id, status: 1)
  end

  def send_email_to_lead_rescuer
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
    slot.even? ? slot/2 : slot.to_i/2 + 1
  end
  
  def full?
    slot <= attending_user_count
  end

  def need_help?
    starting_time.between?( Time.current, Time.current + 1.week ) && attending_user_count < (slot / 2)
  end

  def wait_list_full?
    waiting_list_slot ||= 0
    waiting_list_slot <= waiting_user_count
  end

  def participation_status_editable?
    self.starting_time > Time.current
  end

  def change_leader
    if leader_id_changed? && can_change_leader?
      #remove old leader from the event
      old_leader_event_relationship = UsersEvents.find_by_user_id_and_event_id(leader_id_was, id)
      old_leader_event_relationship.destroy if old_leader_event_relationship
      #make new leader attend the event
      sign_up_lead_rescuer
      send_email_to_lead_rescuer
    end
  end

  def is_not_leader?(user_id)
    leader_id != user_id
  end

  def can_change_leader?
    if starting_time
      Time.current + 5.hours < starting_time
    else
      true
    end
  end

  def main_recurring_event_id
    return nil if not_recurring?
    parent_event_id || id
  end

  #####################################################################
  # Validation
  #####################################################################
  def starting_time_after_current_time
    if starting_time && starting_time < Time.current
      errors[:base] << "Event starting time can not be older than current time"
    end
  end

  def starting_time_before_ending_time
    return if self.starting_time.nil? || self.ending_time.nil?
    if self.starting_time > self.ending_time
      errors[:base] << "Event starting time can not after ending time"
    end
  end

  def finish_process
    errors[:base] << "pound is required!" if pound.nil?
    if pound != 0 && self.receipt.nil?
      errors[:base] << "receipt is required!"
    end
  end

  def leader_validation
    if leader
      return errors[:base] << "Only confirmed user can be leader of an event" unless leader.confirmed?
      return errors[:base] << "Normal user can not be leader of an event" unless leader.admin?
    end
  end
  
  class << self

    def create_recurring_events( event, recurring_ending_date, event_days = nil )
      return if event.nil? || event.not_recurring? || !recurring_ending_date.present? #no recurring event
      selected_time = self.calculate_recurring_time( event, recurring_ending_date, event_days )

      parent_event_id = event.parent_event_id || event.id
      event_params = selected_time.map do |time|
        {  
          title: event.title,
          description: event.description,
          slot: event.slot,
          address: event.address,
          location_id: event.location_id,
          category_id: event.category_id,
          instruction_id: event.instruction_id,
          recurring_type: event.recurring_type,
          leader_id: event.leader_id,
          parent_event_id: parent_event_id,
          starting_time: time[:starting_time],
          ending_time: time[:ending_time]
        }
      end

      e = Event.create(event_params)
    end

    def calculate_recurring_time( event, recurring_ending_date, event_days = nil )
      event_days = event_days.map { |day| day.to_i } if event_days
      starting_date = event.starting_time.to_date + 1.day
      ending_date = parse_event_date(recurring_ending_date)
      # check if ending date time is later than the event ending time, exclude or include the ending day depends on the result
      ending_date = ending_date.seconds_since_midnight > event.starting_time.seconds_since_midnight ? ending_date.to_date : (ending_date - 1.day).to_date

      if event.daily?
        selected_date = (starting_date..ending_date).to_a.select {|date| event_days.include?(date.wday) }
      elsif event.weekly?
        selected_date = (starting_date..ending_date).to_a.select {|date| event.starting_time.wday == date.wday }
      elsif event.monthly?
        selected_date = (starting_date..ending_date).to_a.select {|date| event.starting_time.mday == date.mday }
      end

      selected_time = selected_date.map do |date| 
        { starting_time: date + event.starting_time.seconds_since_midnight.seconds, ending_time: date + event.ending_time.seconds_since_midnight.seconds } 
      end
    end

    def parse_event_date(time_string)
      date = Date._strptime(time_string, '%m/%d/%Y %I:%M %p')
      Time.zone.local(date[:year], date[:mon], date[:mday], date[:hour], date[:min], 0)
    end

  end

end
