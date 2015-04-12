class PageObserver < ActiveRecord::Observer

  def after_create page
    PusherJob.perform_later 'create', page
    WaybackJob.new.async.perform page.url
  end

  def after_update page
    PusherJob.perform_later 'update', page
  end

  def after_destroy page
    PusherJob.perform_later 'destroy', page
  end

end
