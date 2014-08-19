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
        RemindLeaderEmailWorker::perform_at(@event.ending_time, current_user.id, @event.id)
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
        if @type == 'attend'
          AttendEmailWorker::perform_async(current_user.id, @event.id)
          if Time.current < @event.starting_time - 24.hour # event happened later than attending time
            ReminderEmailWorker::perform_at(@event.starting_time - 24.hour, current_user.id, @event.id)
          end
        elsif @type == 'wait'
          WaitingListEmailWorker::perform_async(current_user.id, @event.id)
        end 
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
        CancelEmailWorker::perform_async(current_user.id, @event.id)
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
    UsersEvents.where('user_id IN (?) AND event_id = ?', params["user_ids"], params["event_id"]).update_all("status = 3")
    params["user_ids"].each do |user_id|
      ThankEmailWorker::perform_async(user_id, params["event_id"])
    end if params["user_ids"]

    if params["image"]
      @image = Image.new(event_id: params["event_id"], file: params["image"])
      @image.save
    end

    @receipt = Image.new(event_id: params["event_id"], file: params["receipt"], is_receipt: true)

    if @receipt.save
      event = Event.find_by_id(params["event_id"])
      event.update_attributes(is_finished: true, pound: params["pound"])
      flash[:notice] = "You successfully finished the event! thank you"
    end
    redirect_to :back
  end

  def photo
    @images = @event.images
    @receipt = @event.receipt
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
      params.require(:event).permit(:title, :date, :starting_time, :ending_time, :slot, :slot_remaing, :address, :location_id, :description, :recurring_type, :category_id, :leader_id, :pound, :is_finished, :parent_event_id)
    end

end
