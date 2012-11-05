class CommentObserver < ActiveRecord::Observer

  def after_create comment
    Broadcaster::signal :create, comment
    comment.user.hooks.each do |hook| hook.run(comment, :comment) end

    # Send mention emails
    User.mentioned_in(comment).where('id != ?', comment.user_id).each do |user|
      if !user.email.blank? and user.email_when_mentioned
        comment.is_a_show ? UserMailer.delay.shown_a_page(comment, user)
                           : UserMailer.delay.mentioned(comment, user)
      end
    end
  end

  def after_update comment
    Broadcaster::signal :update, comment
  end

  def after_destroy comment
    Broadcaster::signal :destroy, comment
  end

end
