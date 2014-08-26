class UserMailer < Devise::Mailer
  layout 'email_layout' 
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  before_action :attachment_image
  
  default from: 'volunteer@rescuingleftovercuisine.org'

  def confirmation_instructions(record, token, opts={})
    if record.is_under_eighteen
      attachments["RLC_Parental_Guardian_Consent_Form.pdf"] = File.read("#{Rails.root}/app/assets/files/parents_guardian_form.pdf")
    end
    @is_under_eighteen = record.is_under_eighteen
    super
  end

  private

  def attachment_image
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
  end
end