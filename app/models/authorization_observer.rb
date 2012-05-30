class AuthorizationObserver < ActiveRecord::Observer

  def before_save(auth)
    # convert timestamp to datetime
    auth.expires_at = Time.at(auth.expires_at) rescue nil
    auth.refresh_token if !auth.expires_at.blank? and auth.expires_at < 7.days.from_now
    auth.sync_perms
  end

end
