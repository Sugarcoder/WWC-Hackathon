require 'open-uri'
class EventMailer < ActionMailer::Base
  layout 'email_layout'
  default from: 'volunteer@rescuingleftovercuisine.org'
  before_action :attachment_image
  
  RLC_VOLUNTEER_EMAIL = 'volunteer@rescuingleftovercuisine.org'

  def cancel_email(user, event)
    @user = user
    @event = event
    subject = "Cancellation: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    mail(to: user.email, subject: subject)
  end

  def attend_email(user, event, event_leader, summary = nil)
    @user = user
    @event = event
    @event_leader = event_leader
    @summary = summary
    subject = "Confirmation: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments['instruction.pdf'] = File.read(open(event.instruction.url)) if event.instruction?
    mail(to: user.email, subject: subject)
  end

  def leader_attend_email(leader, event, attend_user_list)
    @user = leader
    @event = event
    @attend_user_list = attend_user_list
    subject = "Attendance for RLC Event #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments['instruction.pdf'] = File.read(open(event.instruction.url)) if event.instruction?
    mail(to: leader.email, subject: subject)
  end

  def waiting_list_email(user, event)
    @user = user
    @event = event
    subject = "Waitlist Confirmation: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    mail(to: user.email, subject: subject)
  end

  def waiting_to_attend_email(user, event)
    @user = user
    @event = event
    subject = "Get off the Waitlist: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    mail(to: user.email, subject: subject)
  end

  def reminder_email(user, event, event_leader)
    @user = user
    @event = event
    @event_leader = event_leader
    subject = "Reminder: Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    attachments['instruction.pdf'] = File.read(open(event.instruction.url)) if event.instruction?
    mail(to: user.email, subject: subject)
  end

  def thank_user_email(user, event)
    @user = user
    @event = event
    subject = "Thank you for your help in Rescuing Leftover Cuisine at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    mail(to: user.email, subject: subject)
  end

  def remind_leader_email(user, event)
    @user = user
    @event = event
    subject = "Reminder: Finish your event online! Thank You for Leading RLC Event at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    mail(to: user.email, subject: subject)
  end

  ########################################

  def comment_email(user, event, comment)
    @user = user
    @event = event
    @comment = comment
    subject = "New Comment Notification: #{user.full_name} left a comment at #{event.title.titleize} on #{event.starting_time.strftime('%B %e')}"
    mail(to: RLC_VOLUNTEER_EMAIL, subject: subject)
  end

  private

  def attachment_image
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/RLC_LOGO_small.png")
  end

end