class CommentObserver < ActiveRecord::Observer

  def after_create comment
    PusherJob.new.async.perform :create, comment
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
      if !user.email.blank? and user.email_when_mentioned and comment.user.can_play_with(user)
        comment.is_a_show ? UserMailerShownAPageJob.new.async.perform(comment, user)
                          : UserMailerMentionedJob.new.async.perform(comment, user)
      end
    end
  end

  def after_update comment
    PusherJob.new.async.perform :update, comment
  end

  def after_destroy comment
    PusherJob.new.async.perform :destroy, comment
  end

end
