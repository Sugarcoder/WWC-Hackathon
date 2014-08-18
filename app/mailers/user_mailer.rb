class UserMailer < Devise::Mailer
  layout 'email_layout' 
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  
  default from: 'volunteer@rescuingleftovercuisine.org'

  def confirmation_instructions(record, token, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    @is_under_eighteen = record.is_under_eighteen
    super
  end


end