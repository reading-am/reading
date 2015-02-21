class RelationshipObserver < ActiveRecord::Observer

  def after_create(rel)
    if rel.followed.email_when_followed and rel.followed.email and rel.follower.can_play_with(rel.followed)
      UserMailer.new_follower(rel.followed, rel.follower).deliver_later
    end
  end

end
