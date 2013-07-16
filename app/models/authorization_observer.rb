class AuthorizationObserver < ActiveRecord::Observer

  def before_save(auth)
    # convert timestamp to datetime
    auth.refresh_token if !auth.expires_at.blank? and auth.expires_at < 7.days.from_now
    auth.sync_perms # it might be aggressive to call this here
  end

  def before_create(auth)
    case auth.provider
    when "tssignals"
      indexes = auth.info["accounts"].collect.with_index{|a,i| i if a["product"] == "campfire"}.compact
      indexes.each do |i|
        response = Typhoeus::Request.get "https://#{URI.parse(auth.info["accounts"][i]["href"]).host}/users/me.json", :params => {:access_token => auth.token}
        response = ActiveSupport::JSON.decode response.body
        auth.info["accounts"][i]["api_auth_token"] = response["user"]["api_auth_token"]
      end
    end
  end

end
