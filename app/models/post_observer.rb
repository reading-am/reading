class PostObserver < ActiveRecord::Observer

  def after_create post
    post.user.hooks.each do |hook| hook.run(post, 'new') end
    if !post.yn.nil?
      post.user.hooks.each do |hook| hook.run(post, post.yn ? 'yep' : 'nope') end
    end
    PusherJob.perform_later 'create', post
  end

  def after_update post
    if post.yn_changed? and !post.yn.nil?
      post.user.hooks.each do |hook| hook.run(post, post.yn ? 'yep' : 'nope') end
    end
    PusherJob.perform_later 'update', post
  end

  def after_destroy post
    PusherJob.perform_later 'destroy', post
  end

end
