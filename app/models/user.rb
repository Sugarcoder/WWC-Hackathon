class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
  has_many :users_events, :foreign_key => 'user_id', :class_name => "UsersEvents"
  has_many :attending_events, -> { where "status = 1" }, through: :users_events, source: :event
  has_many :waiting_events, -> { where "status = 2" }, through: :users_events, source: :event
  has_many :attended_events, -> { where "status = 3" }, through: :users_events, source: :event

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
end
