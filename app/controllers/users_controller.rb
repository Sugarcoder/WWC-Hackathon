class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :avatar, :upload_avatar, :events]

  def index
    
  end

  def show
    @user = User.find_by_id(params[:id])
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
    case params['type']
    when 'upcoming' 
      @events = Event.where( ' id IN (?) and starting_time > ?', event_ids, Time.now ).order('starting_time ASC')
      @status = 'reserved'
    when 'history'
      @events = Event.where( ' id IN (?) and starting_time < ?', event_ids, Time.now ).order('starting_time DESC')
      @status = 'attended'
    end
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