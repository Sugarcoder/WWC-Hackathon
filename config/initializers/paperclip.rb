Paperclip::Attachment.default_options.merge!({
  bucket: "rlc-#{Rails.env}",
  :storage => :s3,
  s3_credentials: Rails.configuration.aws,
  s3_host_name:  's3.amazonaws.com'
}) unless Rails.env.test?

require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end

  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        crop_command + super.join(' ').sub(/ -crop \S+/, '').split(' ')
      else
        super
      end
    end
 
    def crop_command
      target = @attachment.instance
      if target.cropping?
        ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
      end
    end
  end

end

