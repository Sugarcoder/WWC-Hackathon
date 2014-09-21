class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  enum role: [ :normal, :admin, :super_admin ]
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
  has_many :users_events, :foreign_key => 'user_id', :class_name => "UsersEvents"
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  has_attached_file :avatar, styles: {
    square: { geometry: '140x140#', format: 'jpg' }
  }, :default_url => "user.png", :processors => [:cropper]
  do_not_validate_attachment_file_type :avatar

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    path = (avatar.options[:storage]==:s3) ? avatar.url(style) : avatar.path(style)
    @geometry[style] ||= Paperclip::Geometry.from_file(path)
  end

  def full_name
    firstname[0] = firstname[0].capitalize if firstname.present?
    lastname[0] = lastname[0].capitalize if lastname.present?
    case
      when firstname.present? && lastname.present?
        "#{firstname} #{lastname}"
      when firstname.present?
        "#{firstname}"
      when lastname.present?
        "#{lastname}"
      else
        ""
    end
  end

  def attending_events( options = {} )
    events( 'attending', options )
  end

  def attended_events( options = {} )
    events( 'attended', options )
  end

  def unfinished_events( options = {} )
    events( 'unfinished', options )
  end

  def finished_events( options = {} )
    events( 'finished', options )
  end

  def attend_event(event)
    return nil unless event.present? && event.is_a?(Event)
    user_event = UsersEvents.create(user_id: id, event_id: event.id, status: 1)
  end

  def attending_event?(event, user_event_relationship = nil)
    check_user_event_relationship(event, 'attending', user_event_relationship = nil)
  end  

  def waiting_event?(event, user_event_relationship = nil)
    check_user_event_relationship(event, 'waiting', user_event_relationship = nil)
  end

  def attend_recurring_event?(event, user_event_relationship = nil)
    check_user_event_relationship(event, 'recurring', user_event_relationship = nil)
  end

  def change_user_role(email, type)
    return { error: true, message: 'Only super admin could upgrade user'} unless self.super_admin?
    return { error: true, message: 'Email is required'} unless email.present?
    user = User.find_by_email(email)
    return { error: true, message: 'User not found'} if user.nil?
    case type
    when 'upgrade_to_lead_rescuer'
      upgrade_to_lead_rescuer(user)
    when 'downgrade_to_normal_user'
      downgrade_to_normal_user(user)
    end
  end

  def is_leader?(event)
    id == event.leader_id
  end

  def can_finish_event?(event)
    is_leader?(event) || super_admin?
  end

  private

  def upgrade_to_lead_rescuer(user)
    if user.normal?
      if user.update_attribute('role', 1) 
        { error: false, message: "User with email #{user.email} is upgraded to lead rescuer" } 
      else
        { error: true, message: user.errors.full_messages } 
      end
    else
       { error: true, message: "The user is a #{user.role}. Only normal user could be upgraded" } 
    end
  end

  def downgrade_to_normal_user(user)
    if user.admin?
      if user.update_attribute('role', 0) 
        { error: false, message: "User with email #{user.email} is downgraded to normal user" } 
      else
        { error: true, message: user.errors.full_messages } 
      end
    else
       { error: true, message: "The user is a #{user.role}. Only lead rescuer could be downgraded" } 
    end
  end

  def check_user_event_relationship(event, type, user_event_relationship)
    return false if event.nil?
    user_event_relationship = user_event_relationship || UsersEvents.find_by_event_id_and_user_id(event.id, self.id)
    return false if user_event_relationship.nil?
    case type
    when 'attending'
      user_event_relationship.attending?
    when 'waiting'
      user_event_relationship.waiting?
    when 'recurring'
      user_event_relationship.attend_recurring?
    end
  end

  def events( event_type, options = {} )
    events = []
    page, per_page = paginate_option( options )

    events =  case event_type
              when 'attending'
                Event.joins(:users_events).where( " user_id = #{id} AND status = 1 " ).start_after( Time.current ).order( 'starting_time ASC' )
              when 'attended'
                Event.joins(:users_events).where( " user_id = #{id} AND status = 3 " ).start_before( Time.current ).order( 'starting_time DESC' )
              when 'unfinished'
                if super_admin? 
                  Event.not_finished.end_before( Time.current ).order( 'ending_time ASC' )
                else
                  Event.with_leader(id).not_finished.end_before( Time.current ).order( 'ending_time ASC' )
                end
              when 'finished'
                if super_admin?
                  Event.includes(:events_categories).finished.order( 'updated_at DESC' )
                else
                  Event.includes(:events_categories).with_leader(id).finished.order( 'updated_at DESC' )
                end
              end

    return  [ [], 0 ] unless events.present?
    count  = events.count
    events = events.paginate( page: page, per_page: per_page )
    return [ events, count ]
  end

  def paginate_option( options = {} )
    page = options[:page].present? ? options[:page] : 1
    per_page = options[:per_page].present? ? options[:per_page] : 10
    [page, per_page]
  end
  
end
