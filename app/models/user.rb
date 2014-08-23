class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  enum role: [ :normal, :admin, :super_admin ]
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
  has_many :users_events, :foreign_key => 'user_id', :class_name => "UsersEvents"
  has_many :leading_events, foreign_key: 'leader_id', class_name: 'Event'

  has_many :attending_events, -> { where "status = 1" }, through: :users_events, source: :event
  has_many :waiting_events, -> { where "status = 2" }, through: :users_events, source: :event
  has_many :attended_events, -> { where "status = 3" }, through: :users_events, source: :event
  has_many :attending_recurring_events, -> { where "status = 1 and parent_id is not null" }, through: :users_events, source: :event
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  has_attached_file :avatar, styles: {
    square: { geometry: '140x140#', format: 'jpg' }
  }, :default_url => "/assets/user.png", :processors => [:cropper]
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

  def attending_event?(event, user_event_relationship = nil)
    check_user_event_relationship(event, 'attending', user_event_relationship = nil)
  end  

  def waiting_event?(event, user_event_relationship = nil)
    check_user_event_relationship(event, 'waiting', user_event_relationship = nil)
  end

  def attend_recurring_event?(event, user_event_relationship = nil)
    check_user_event_relationship(event, 'recurring', user_event_relationship = nil)
  end

  private

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
  
end
