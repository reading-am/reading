class PageObserver < ActiveRecord::Observer

  def after_create page
    Broadcaster::signal :create, page
  end

  def after_update page
    Broadcaster::signal :update, page
  end

  def after_destroy page
    Broadcaster::signal :destroy, page
  end

end
