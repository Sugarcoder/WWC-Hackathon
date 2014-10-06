class Instruction < ActiveRecord::Base
  has_many :events

  validates :description, presence: true

  has_attached_file :file
  validates_attachment :file, content_type: { content_type: "application/pdf" }
end
