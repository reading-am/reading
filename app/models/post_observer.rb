class PostObserver < ActiveRecord::Observer

  def after_create post
    Broadcaster::signal :create, post
  end

  def after_update post
    Broadcaster::signal :update, post
  end

  def after_destroy post
    Broadcaster::signal :destroy, post
  end

end
