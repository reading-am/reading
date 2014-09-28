class BlockageObserver < ActiveRecord::Observer

  def after_create(blk)
    AdminMailerNewBlockageJob.new.async.perform(blk.blocked, blk.blocker)
  end

  def after_destroy(blk)
    AdminMailerBlockageRemovedJob.new.async.perform(blk.blocked, blk.blocker)
  end

end
