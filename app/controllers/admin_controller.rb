class AdminController < ApplicationController
  authorize_resource :class => false
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

  def get_user_reports
    render text: self.get_current_lead_rescuers()
  end


  # Helpers to export data for all users 
  # Note: Duplicated to avoid modifying with existing code while putting a hack in to 
  # give Ryan access to data
  # Should refactor get_current_lead_rescuers to use the User#events method
  # CSV Export of "Current Lead Rescuers"
  def events_for_user(user, event_type, options = {} )
    events = []
    events =  case event_type
    when 'attending'
      Event.joins(:users_events).where( " user_id = #{user.id} AND status = 1 " ).start_after( Time.current ).order( 'starting_time ASC' )
    when 'attended'
      Event.joins(:users_events).where( " user_id = #{user.id} AND status = 3 " ).start_before( Time.current ).order( 'starting_time DESC' )
    when 'unfinished'
      if user.super_admin?
        Event.not_finished.end_before( Time.current ).order( 'ending_time ASC' )
      else
        Event.with_leader(user.id).not_finished.end_before( Time.current ).order( 'ending_time ASC' )
      end
    when 'finished'
      if user.super_admin?
        Event.includes(:events_categories).finished.order( 'updated_at DESC' )
      else
        Event.includes(:events_categories).with_leader(user.id).finished.order( 'updated_at DESC' )
      end
    end
    return events
  end

  def get_current_lead_rescuers
    result = ""
    headers = [
      'ID',
      'First Name',
      'Last Name',
      'Email',
      'Date Created',
      '# of Events Led',
      '# of Events Attended',
      '# of Events Cancelled'
    ]

    result += headers.join(';')
    User.all.each do |user|
      result += [
        user.id,
        user.firstname,
        user.lastname,
        user.email,
        user.created_at,
        events_for_user(user, 'attended').count,
      Event.where(:leader_id => user.id).count, # # of events led
      '???'
      ].join(';')
      result += "\n"
    end
    return result
  end

end