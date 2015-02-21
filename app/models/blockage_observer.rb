class BlockageObserver < ActiveRecord::Observer

  def after_create(blk)
    AdminMailer.new_blockage(blk.blocked, blk.blocker).deliver_later
  end

  def after_destroy(blk)
    AdminMailer.blockage_removed(blk.blocked, blk.blocker).deliver_later
  end

end
