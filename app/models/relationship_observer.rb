class RelationshipObserver < ActiveRecord::Observer

  def after_create(rel)
    if rel.followed.email_when_followed && rel.followed.email
      UserMailerNewFollowerJob.new.async.perform(rel.followed, rel.follower)
    end
  end

end
