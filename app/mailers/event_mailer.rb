class EventMailer < ActionMailer::Base
  layout 'email_layout'
  default from: 'info@rescuingleftovercuisine.org'
 
  def cancel_email(user, event)
    @user = user
    @event = event
    subject = "Cancellation: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    mail(to: user.email, subject: subject)
  end

  def attend_email(user, event, event_leader)
    @user = user
    @event = event
    @event_leader = event_leader
    subject = "Confirmation: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    mail(to: user.email, subject: subject)
  end

  def waiting_list_email(user, event)
    @user = user
    @event = event
    subject = "Waitlist Confirmation: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    mail(to: user.email, subject: subject)
  end

  def reminder_email(user, event, event_leader)
    @user = user
    @event = event
    @event_leader = event_leader
    subject = "Reminder: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    mail(to: user.email, subject: subject)
  end

  def thank_user_email(user, event)
    @user = user
    @event = event
    subject = "Thank you for your help in Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    mail(to: user.email, subject: subject)
  end

  def remind_leader_email(user, event)
    @user = user
    @event = event
    subject = "Thank You for Leading RLC Event at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
    mail(to: user.email, subject: subject)
  end

end