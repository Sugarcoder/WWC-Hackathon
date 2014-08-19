class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    event = Event.find_by_id(params[:event_id])
    comment = Comment.build_from( event, current_user.id, params["text"] )
    comment.save
    @user = current_user
    render partial: 'comment', locals: { user: current_user , comment: comment }
  end

  def destroy
    comment = Comment.find_by_id(params[:id])
    if comment.destroy
      return render json: { error: false, message: 'Comment deleted'}
    else
      return render json: { error: true, message: comment.errors.full_messages}
    end
  end

  def loadmore
    comments_per_page = 10
    comments = Comment.includes(:user).where(commentable_id: params["event_id"]).paginate(page: params["page"], per_page: comments_per_page).order('created_at DESC')
    render partial: 'comments', locals: { event_id: params["event_id"], comments: comments, page: params["page"].to_i + 1 }, layout: false
  end 

end
