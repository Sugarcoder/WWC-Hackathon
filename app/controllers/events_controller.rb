class EventsController < ApplicationController
  include EventsHelper
  load_and_authorize_resource 
  skip_authorize_resource :only => :calendar
  before_action :authenticate_user!, only: [:attend, :cancel, :stop_recurring, :finish]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    comments_per_page = 10
    @comments = Comment.where(commentable_id: @event.id).paginate(page: 1, per_page: comments_per_page).order('created_at DESC')
    @users = User.joins(:users_events).where('event_id = ?', @event.id)
    respond_to do |format|
      format.js { render  'show' }
      format.html { render 'show' }
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    @starting_time = @event.starting_date
    @ending_time = @event.ending_date
  end

  # POST /events
  # POST /events.json
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

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
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

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def calendar
    if params["location"] && params["location"] != "all"
      location = Location.find_by_name(params["location"])
      @events = location.events if location
    else
      @events = Event.all
    end

    @events_by_date = @events.group_by{|e| e.starting_time.strftime("%Y-%m-%d") if e.starting_time}
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @locations = Location.all
   
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
      message = events.errors.full_message
    end
    respond_to do |format|
      format.json { render json: { error: error, message: message} }
    end
  end

  def finish_form
    @status = 'unfinished'
    user_ids = UsersEvents.where('event_id = ?', @event.id).map(&:user_id)
    @event_users = User.where('id IN (?)', user_ids)
  end

  def finish
    
    if params["image"].present?
      @image = Image.new(event_id: params["event_id"], file: params["image"])
      @image.save
    end

    if params["receipt"].present?
      @receipt = Image.new(event_id: params["event_id"], file: params["receipt"], is_receipt: true)
      @receipt.save
    end
  
    event = Event.find_by_id(params["event_id"])
    if event.is_finished 
      flash[:alert] = 'The event is already finished.'
    else
      if event.update_attributes(is_finished: true, pound: params["pound"])
        UsersEvents.where('user_id IN (?) AND event_id = ?', params["user_ids"], params["event_id"]).update_all("status = 3")
        params["user_ids"].each do |user_id|
          ThankEmailWorker::perform_async(user_id, params["event_id"])
        end if params["user_ids"]
        flash[:notice] = "You successfully finished the event! thank you"
      else
        flash[:alert] = event.errors.full_messages.join(", ")
      end
    end
    
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
        time_interval = (weekly_count) * 7
        ending_date = Event.parse_event_date(params['attend_recurring_ending_date'])
        dates = []

        today_number = Time.current.wday == 0 ? Time.current.wday + 7 : Time.current.wday
        weekdays.each do |day_number|
          day_number = 7 if day_number == 0
          if day_number > today_number
            starting_date = @event.starting_time.beginning_of_week + (day_number-1).days + (@event.starting_time.seconds_since_midnight.seconds)
          else
            starting_date = @event.starting_time.next_week + (day_number - 1).days + (@event.starting_time.seconds_since_midnight.seconds)
          end
          dates << starting_date if starting_date < ending_date
        end

        summary = Event.attend_recurring_summary(weekly_count, dates)      

        dates.each do |date|
          break if date >= ending_date 
          new_date = date + time_interval.days
          dates << new_date if new_date < ending_date
        end

        parent_event_id = @event.parent_event_id || @event.id
        event_ids = Event.where('parent_event_id = ? and starting_time IN (?)', parent_event_id, dates).map(&:id)
        
        record = UsersEvents.create(user_id: current_user.id, event_id: @event.id, status: 1)
        event_ids.each {|id| UsersEvents.create(user_id: current_user.id, event_id: id, status: 1, parent_id: record.id, summary: summary)}
        

        flash[:notice] = summary
      end
    end

    redirect_to :back
  end

  def stop_attend_recurring
    users_event = UsersEvents.find_by_user_id_and_event_id(current_user.id, @event.id)
    parent_id = users_event.parent_id ? users_event.parent_id : users_event.id
    users_events = UsersEvents.joins(:event).where('user_id = ? and parent_id = ? and starting_time > ?', current_user.id, parent_id, @event.starting_time )
    users_events.destroy_all
    users_event.destroy
    flash[:alert] = 'all future events that is related to this recurring event canceled'
  
    return redirect_to :back
  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params['event']['starting_time'] = Event.parse_event_date(params['event']['starting_time']) if params['event']['starting_time'].present?   
      params['event']['ending_time'] = Event.parse_event_date(params['event']['ending_time'])  if params['event']['ending_time'].present?
      params.require(:event).permit(:title, :date, :starting_time, :ending_time, :slot, :slot_remaing, :address, :location_id, :description, :recurring_type, :category_id, :leader_id, :pound, :is_finished, :parent_event_id, :instruction)
    end

end
