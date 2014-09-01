class PageObserver < ActiveRecord::Observer

  def after_create page
    PusherJob.new.async.perform :create, page
    WaybackJob.new.async.perform page.url
  end

  def after_update page
    PusherJob.new.async.perform :update, page
  end

  def after_destroy page
    PusherJob.new.async.perform :destroy, page
  end

end
