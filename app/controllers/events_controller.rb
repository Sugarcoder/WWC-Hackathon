class EventsController < ApplicationController
  include EventsHelper
  include ActiveModel::Dirty
  include EventsCategoriesHelper

  load_and_authorize_resource 
  skip_authorize_resource only: [:calendar, :show]
  before_action :authenticate_user!, only: [:attend, :cancel, :stop_recurring, :finish]

  def index
    @events = Event.all
  end

  def show
    comments_per_page = 10 
    @comments = Comment.where(commentable_id: @event.id).paginate(page: 1, per_page: comments_per_page).order('created_at DESC')
    @users = User.joins(:users_events).where('event_id = ?', @event.id)
    respond_to do |format|
      format.js { render  'show' }
      format.html { render 'show' }
    end
  end

  def new
    @event = Event.new
  end

  def edit
    @starting_time = @event.starting_date
    @ending_time = @event.ending_date
  end

  def create
    respond_to do |format|
      if @event.save
        Event.create_recurring_events(params['event']['recurring_type'], params['recurring_ending_date'], @event)
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update 
    respond_to do |format|
      if @event.update_attributes(event_params)
        Event.create_recurring_events(params['event']['recurring_type'], params['recurring_ending_date'], @event)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def calendar
    if params[:date]
      @date = Date.parse(params[:date])
      starting_time = @date.to_time.beginning_of_month
      ending_time = @date.to_time.end_of_month
    else
      @date = Date.today
      starting_time = Time.current.beginning_of_month
      ending_time = Time.current.end_of_month
    end

    @location_name = params["location"]

    if @location_name && @location_name != "all"
      location = Location.find_by_name(params["location"])
      @events = location.events.within_time_range(starting_time, ending_time) if location
    else
      @events = Event.within_time_range(starting_time, ending_time)
    end

    @events_by_date = @events.group_by{|e| e.starting_time.strftime("%Y-%m-%d")}
   
    @locations = Location.all.sort_by{ |location| location.name.downcase }
   
    render 'daily_calendar' if params[:type] == 'daily'
  end

  def attend
    @type = params[:status]
    @event = Event.find_by_id(params[:event_id])
    return render 'attend' if @event.nil?

    case @type
    when 'attend'
      users_events = UsersEvents.new(user_id: current_user.id, event_id: params[:event_id], status: 1)
      notice = 'You successfully registered for this event.'
    when 'wait'
      users_events = UsersEvents.new(user_id: current_user.id, event_id: params[:event_id], status: 2)
      notice = 'You successfully joined the waiting list for this event.'
    end

    respond_to do |format|
      if users_events.save
        format.html { redirect_to :back, notice: notice }
        format.js{ render 'attend'}
        format.json { render json: { event_id: @event.id} }
      else
        format.html { redirect_to :back, alert: users_events.errors.full_messages.join(', ') }
        format.json { head :no_content }
      end
    end
  end

  def cancel
    @type = params[:status]
    @event = Event.find_by_id(params[:event_id])
    case @type
    when 'attend'
      users_events = UsersEvents.find_by_user_id_and_event_id_and_status(current_user.id, params[:event_id], 1)
    when 'wait'
      users_events = UsersEvents.find_by_user_id_and_event_id_and_status(current_user.id, params[:event_id], 2)
    end

    respond_to do |format|
      if users_events.destroy
        notice = 'You canceled this event.'
        format.html { redirect_to :back, alert: notice }
        format.json { render json: { event_id: @event.id} }
      else
        format.html { redirect_to :back, alert: users_events.errors.full_messages.join(', ') }
        format.json { head :no_content }
      end
    end
  end

  def stop_recurring
    @event.update_attribute('recurring_type', 'not_recurring');
    parent_event_id = @event.parent_event_id.present? ? @event.parent_event_id : @event.id 
    events = Event.where('starting_time > ? and parent_event_id = ?', @event.starting_time, parent_event_id)
    if events.destroy_all
      error = false
      message = 'remove recurring events after this event'
    else
      error = true
      message = events.errors.full_messages
    end
    respond_to do |format|
      format.json { render json: { error: error, message: message} }
    end
  end

  def new_finish
    @status = 'edit_finish' if params[:status] == 'edit'
    @event_attendees = @event.attendees
  end

  def finish
    if params["image"].present?
      @image = Image.create(event_id: @event.id, file: params["image"])
    end

    if params["receipt"].present?
      @receipt = Image.create(event_id: @event.id, file: params["receipt"], is_receipt: true)
    end
  
    finish_event = FinishEvent.new(params['pound'], params['category_pounds'], params['category_ids'], params['user_ids'])
    result = finish_event.run(@event)

    if result["error"]
      flash[:alert] = result['message']
    else
      flash[:notice] = result['message']
    end

    redirect_to user_events_path(current_user, 'finished')
  end

  def update_finish
    if params["image"].present?
      @image = Image.create(event_id: params["event_id"], file: params["image"])
    end

    if params["receipt"].present?
      old_receipt = Image.find_by_event_id_and_is_receipt(params["event_id"], true)
      old_receipt.destroy if old_receipt
      @receipt = Image.create(event_id: params["event_id"], file: params["receipt"], is_receipt: true)
    end

    finish_event = FinishEvent.new(params['pound'], params['category_pounds'], params['category_ids'], params['user_ids'])
    finish_event.update(@event)

    redirect_to :back
  end

  def photo
    @images = @event.images
    @receipt = @event.receipt
  end

  def attend_recurring

    if @event.daily?
      if params['day'] && params['attend_recurring_ending_date']
        weekdays = params['day'].map(&:to_i)
        weekly_count = params['weekly_count'].to_i
        starting_date = @event.starting_time
        ending_date = Event.parse_event_date(params['attend_recurring_ending_date'])

        attend_recurring_event = AttendRecurringEvent.new(starting_date, ending_date, weekly_count, weekdays)
        summary = attend_recurring_event.run(current_user, @event)    

        flash[:notice] = summary
      end
    end

    redirect_to :back
  end

  def stop_attend_recurring
    users_events = UsersEvents.joins(:event).where('user_id = ? and parent_id = ? and starting_time >= ?', current_user.id, @event.main_recurring_event_id, @event.starting_time )
    users_events.destroy_all
    flash[:alert] = 'all future events that is related to this recurring event canceled'
    return redirect_to :back
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params['event']['starting_time'] = Event.parse_event_date(params['event']['starting_time']) if params['event']['starting_time'].present?   
      params['event']['ending_time'] = Event.parse_event_date(params['event']['ending_time'])  if params['event']['ending_time'].present?
      params['event']['leader_id'] = get_leader_id_from_email(params['leader_email'])
     
      params.require(:event).permit(:title, :date, :starting_time, :ending_time, :slot, :slot_remaing, :address, :location_id, :description, :recurring_type, :category_id, :leader_id, :pound, :is_finished, :parent_event_id, :instruction)
    end

    def get_leader_id_from_email(email)
      return nil unless email.present?
      user = User.find_by_email(email)
      if user
        user.id
      else
        nil
      end
    end

end
