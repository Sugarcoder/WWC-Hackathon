class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :avatar, :upload_avatar, :events]
  authorize_resource 
  skip_authorize_resource  only: [:check_username, :check_email]

  def index
  end

  def show
  end

  def avatar
  end

  def upload_avatar
    @user.update_attributes(user_params)
    if @user.cropping?
      @user.avatar.reprocess!
    end
    render 'show'
  end

  def events
    event_ids = UsersEvents.where(user_id: @user.id).map(&:event_id)
    @type = params['type']
    case @type 
    when 'upcoming' 
      @events = Event.where('id IN (?) and starting_time > ?', event_ids, Time.now ).order('starting_time ASC')
    when 'attended'
      @events = Event.where('id IN (?) and starting_time < ?', event_ids, Time.now ).order('starting_time DESC')
    when 'unfinished'
      @events = Event.where('leader_id = ? and is_finished is not true and ending_time < ?', current_user.id, Time.current ).order('ending_time ASC')
    when 'finished'
      @events = @user.finished_events
    end
  end

  def check_username
    username = params["user"]["username"]
    user = User.where("lower(username) = ?", username.downcase ).first
     if current_user && user && user.username == current_user.username
      is_unique = true
    elsif user
      is_unique = false
    else
      is_unique = true
    end
    return render json: { valid: is_unique }
  end

  def check_email
    user = User.find_by_email(params["user"]["email"])
    if current_user && user && user.email == current_user.email
      is_unique = true
    elsif user
      is_unique = false
    else
      is_unique = true
    end
    return render json: { valid: is_unique }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:avatar, :crop_x, :crop_y, :crop_w, :crop_h)
    end

end