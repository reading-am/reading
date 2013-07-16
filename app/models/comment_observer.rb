class CommentObserver < ActiveRecord::Observer

  def after_create comment
    Broadcaster::signal :create, comment
    comment.user.hooks.each do |hook| hook.run(comment, 'comment') end

    # Create adhoc users from the emails
    # NOTE: uncomment this to allow email mentioning of unregistered users
    #comment.mentioned_emails.each do |email|
      #u = User.new :email => email
      #u.password_required = false
      #u.save
    #end

    # Send mention emails
    comment.mentioned_users.where('id != ?', comment.user_id).each do |user|
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
