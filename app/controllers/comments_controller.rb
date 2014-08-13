class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    event = Event.find_by_id(params[:event_id])
    comment = Comment.build_from( event, current_user.id, params["text"] )
    comment.save
    redirect_to :back
  end

  def destroy
  end 

end
