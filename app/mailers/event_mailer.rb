class EventMailer < ActionMailer::Base
  layout 'email_layout'
  default from: 'info@rescuingleftovercuisine.org'
 
  def cancel_email(user, event)
    @user = user
    @event = event
    subject = "Cancellation: Rescuing Leftover Cuisine at #{event.title} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO.png")
    mail(to: user.email, subject: subject)
  end
end