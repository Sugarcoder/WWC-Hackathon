class CommentEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(comment_id, options = {})
    comment = Comment.find_by_id(comment_id)
    return if comment.nil?

    user = User.find_by_id(comment.user_id)
    event = Event.includes(:location).find_by_id(comment.commentable_id)
    return if user.nil? || event.nil?
    
    EventMailer.comment_email(user, event, comment).deliver
  end
end