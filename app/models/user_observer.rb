class UserObserver < ActiveRecord::Observer

  def before_save(user)
    # when it's a new user and they have a username
    if (user.username_was.blank? or user.email_was.blank?) and !user.username.blank? and !user.email.blank?

      # Tweet to ReadingArrivals
      if !user.is_og? and Rails.env == 'production'
        tweet = "Everyone welcome #{user.username}! http://#{DOMAIN}/#{user.username}"
        Twitter::Client.new(:oauth_token => "***REMOVED***", :oauth_token_secret => "***REMOVED***").delay.update tweet rescue nil
      end

      UserMailer.delay.welcome(user) unless user.is_og?

    end
  end

end
