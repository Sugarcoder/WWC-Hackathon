class Image < ActiveRecord::Base
 
  before_create :set_orientation

  has_attached_file :file, styles: {
    large:  Proc.new { |a| '600x450>'  },
    small:  Proc.new { |a| '200x150>' }
  }

  validates_attachment :file, content_type: { :content_type => ["image/jpg", "image/jpeg", "image/png"] }
  
  protected

  def set_orientation
     tempfile = file.queued_for_write[:original]
    unless tempfile.nil?
      dimensions = Paperclip::Geometry.from_file(tempfile)
      self.orientation = (dimensions.width > dimensions.height) ? 'landscape' : 'portrait'
    end
  end
end
