class CommentObserver < ActiveRecord::Observer

  def after_save(comment)
    # We treat Pusher just like any other hook except that we don't store it
    # with the user so we go ahead and construct one here
    event = :comment
    Hook.new({:provider => 'pusher', :events => [:new,:yep,:nope,:comment]}).run(comment, event)
    comment.user.hooks.each do |hook| hook.run(comment, event) end

    # These are has_many relationships
    Pusher["pages.#{comment.page_id}.comments"].trigger_async('create', comment.simple_obj)

    # Send mention emails
    User.mentioned_in(comment).where('id != ?', comment.user_id).each do |user|
      if !user.access? :comments
        user.access << :comments
        user.save
        UserMailer.delay.comments_welcome(user, comment) if !user.email.blank?
      end

      if !user.email.blank? and user.email_when_mentioned
        comment.is_a_show ? UserMailer.delay.shown_a_page(comment, user)
                           : UserMailer.delay.mentioned(comment, user)
      end
    end
  end

end
