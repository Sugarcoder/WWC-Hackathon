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
    @type = params['type']
    @page = params['page'].to_i > 0 ?  params['page'].to_i : 1

    case @type 
    when 'upcoming' 
      @events, @events_count = @user.attending_events( page: @page )
    when 'attended'
      @events, @events_count = @user.attended_events( page: @page )
    when 'unfinished'
      @events, @events_count = @user.unfinished_events( page:@page )
    when 'finished'
      @events, @events_count = @user.finished_events( page: @page )
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