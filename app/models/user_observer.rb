class UserObserver < ActiveRecord::Observer

  def before_save(user)
    # when it's a new user and they have a username
    if Rails.env == 'production' && !user.username.blank? && user.username_was.blank?

      # Tweet to ReadingArrivals
      tweet = "Everyone welcome #{user.username}! http://#{DOMAIN}/#{user.username}"
      Twitter::Client.new(:oauth_token => "587119018-Xr0zC5OEqtmIV9MlmUozwvHNZZDZbQ7CwiY2fOQs", :oauth_token_secret => "Kqm1Mzn3HF8HafhLRIlMOJUiPmssD7gGeaVk1SvAmJ4").delay.update tweet rescue nil

      # Auto-follow everyone from their social network
      user.authorizations.first.following.each do |u|
        user.follow!(u)
      end

    end
  end

end
