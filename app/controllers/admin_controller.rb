class AdminController < ApplicationController
  include DateHelper

  def index

  end

  def change_user_role
    result = current_user.change_user_role(params['email'], params['change_action_type'])
    if result[:error]
      redirect_to :back, alert: result[:message]
    else
      redirect_to :back, notice: result[:message]
    end
  end

  def assign_event
    user = User.find_by_email(params['email'])
    event = Event.find_by_id(params['event_id'])
    return redirect_to :back, alert: 'User not found' if user.nil?
    return redirect_to :back, alert: 'Event not found' if event.nil?
    user_event_relationship = UsersEvents.new(user_id: user.id, event_id: event.id, status: 1)
    if user_event_relationship.save
      redirect_to :back, notice: "Assign #{user.full_name} to event #{event.title.titleize} on #{event.starting_date}"
    else
      redirect_to :back, alert: user_event_relationship.errors.full_messages.join(', ')
    end
  end

  def show_pounds_for_categories
    @months = months_of_current_year
    starting_date = params['date'] ? Date.parse(params['date']) : Date.today.beginning_of_month
    ending_date = starting_date.end_of_month
    @date_range = starting_date..ending_date

    @categories = Category.all
  end
  
end
