class EventsController < ApplicationController
  load_and_authorize_resource 
  skip_authorize_resource :only => :calendar
  before_action :authenticate_user!, only: [:attend, :cancel]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
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
    if @event.starting_time
      @date = @event.starting_date
      @starting_time = @event.starting_hour
      @ending_time = @event.ending_hour
    end
  end

  # POST /events
  # POST /events.json
  def create
    if params['event']['date'].present? and params['event']['starting_time'].present?
      params['event']['starting_time'] = parse_event_date(params['event']['date'], params['event']['starting_time'])
    end

    if params['event']['date'].present? and params['event']['starting_time'].present?
      params['event']['ending_time'] = parse_event_date(params['event']['date'], params['event']['ending_time'])
    end

    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
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
    if params['event']['date'].present? and params['event']['starting_time'].present?
      params['event']['starting_time'] = parse_event_date(params['event']['date'], params['event']['starting_time'])
    end
    if params['event']['date'].present? and params['event']['starting_time'].present?
      params['event']['ending_time'] = parse_event_date(params['event']['date'], params['event']['ending_time'])
    end
    respond_to do |format|
      if @event.update(event_params)
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
    @events = Event.all
    @events_by_date = @events.group_by{|e| e.starting_time.strftime("%Y-%m-%d") if e.starting_time}
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
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
        format.html { redirect_to :back, notice: users_events.errors.full_messages.join(', ') }
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
        EventMailer.cancel_email(current_user, @event).deliver if @type == 'attend'
        notice = 'You canceled this event.'
        format.html { redirect_to :back, notice: notice }
        format.json { render json: { event_id: @event.id} }
      else
        format.html { redirect_to :back, notice: users_events.errors.full_messages.join(', ') }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :date, :starting_time, :ending_time, :slot, :slot_remaing, :address, :location_id, :description, :is_recurring, :category_id)
    end

    def parse_event_date(date_string, time_string)
      str = date_string + ' ' + time_string
      date = Date._strptime(str, '%m/%d/%Y %I:%M %p')
      DateTime.new(date[:year], date[:mon], date[:mday], date[:hour], date[:min], 0).to_s
    end
end
