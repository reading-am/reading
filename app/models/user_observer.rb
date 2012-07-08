class UserObserver < ActiveRecord::Observer

  def before_save(user)
    # when it's a new user and they have a username
    if !user.username.blank? && user.username_was.blank?

      # Tweet to ReadingArrivals
      if Rails.env == 'production'
        tweet = "Everyone welcome #{user.username}! http://#{DOMAIN}/#{user.username}"
        Twitter::Client.new(:oauth_token => "***REMOVED***", :oauth_token_secret => "***REMOVED***").delay.update tweet rescue nil
      end

    end
  end

end
