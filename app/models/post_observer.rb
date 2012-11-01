class PostObserver < ActiveRecord::Observer

  def after_create post
    post.user.hooks.each do |hook| hook.run(post, :new) end
    Broadcaster::signal :create, post
  end

  def after_update post
    if post.yn_changed? and !post.yn.nil?
      post.user.hooks.each do |hook| hook.run(post, post.yn ? :yep : :nope) end
    end
    Broadcaster::signal :update, post
  end

  def after_destroy post
    Broadcaster::signal :destroy, post
  end

end
