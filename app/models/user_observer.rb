class UserObserver < ActiveRecord::Observer

  def before_save user
    # when it's a new user and they have a username
    if (user.username_was.blank? or user.email_was.blank?) and !user.username.blank? and !user.email.blank?

      # Tweet to ReadingArrivals
      if !user.is_og? and Rails.env == 'production'
        tweet = "Everyone welcome #{user.username}! http://#{DOMAIN}/#{user.username}"
        Twitter::Client.new(:oauth_token => "587119018-Xr0zC5OEqtmIV9MlmUozwvHNZZDZbQ7CwiY2fOQs", :oauth_token_secret => "Kqm1Mzn3HF8HafhLRIlMOJUiPmssD7gGeaVk1SvAmJ4").delay.update tweet rescue nil
      end

      UserMailer.delay.welcome(user) unless user.is_og?

    end
  end

  def after_create user
    Broadcaster::signal :create, user
  end

  def after_update user
    Broadcaster::signal :update, user
  end

  def after_destroy user
    Broadcaster::signal :destroy, user

    # This email can't be delayed because the user won't exist by the time delayed_job gets to it
    UserMailer.destroyed(user).deliver unless user.email.blank?
  end

end
