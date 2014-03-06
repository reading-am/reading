class PostObserver < ActiveRecord::Observer

  def after_create post
    post.user.hooks.each do |hook| hook.run(post, 'new') end
    if !post.yn.nil?
      post.user.hooks.each do |hook| hook.run(post, post.yn ? 'yep' : 'nope') end
    end
    Broadcaster.new.async.perform :create, post
  end

  def after_update post
    if post.yn_changed? and !post.yn.nil?
      post.user.hooks.each do |hook| hook.run(post, post.yn ? 'yep' : 'nope') end
    end
    Broadcaster.new.async.perform :update, post
  end

  def after_destroy post
    Broadcaster.new.async.perform :destroy, post
  end

end
