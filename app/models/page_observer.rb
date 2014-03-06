class PageObserver < ActiveRecord::Observer

  def after_create page
    Broadcaster.new.async.perform :create, page
  end

  def after_update page
    Broadcaster.new.async.perform :update, page
  end

  def after_destroy page
    Broadcaster.new.async.perform :destroy, page
  end

end
