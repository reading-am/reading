class RelationshipObserver < ActiveRecord::Observer

  def after_create(rel)
    if rel.followed.email_when_followed and rel.followed.email and rel.follower.can_play_with(rel.followed)
      UserMailerNewFollowerJob.new.async.perform(rel.followed, rel.follower)
    end
  end

end
