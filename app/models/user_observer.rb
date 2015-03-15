class UserObserver < ActiveRecord::Observer

  def before_save user
    # when it's a new user and they have a username
    if (user.username_was.blank? or user.email_was.blank?) and !user.username.blank? and !user.email.blank?

      PusherJob.perform_later 'create', user

      # Tweet to ReadingArrivals
      if !user.joined_before_email? and Rails.env == 'production'
        tweet = "Everyone welcome #{user.username}! #{ROOT_URL}/#{user.username}"
        TweetJob.new.async.perform ENV['READING_ARRIVALS_TOKEN'], ENV['READING_ARRIVALS_SECRET'], tweet
      end

      UserMailer.welcome(user).deliver_later unless user.joined_before_email?

    end
  end

  def after_update user
    PusherJob.perform_later 'update', user
  end

  def after_destroy user
    PusherJob.perform_later 'destroy', user

    # This email can't be delayed because the user won't exist by the time it's processed
    UserMailer.destroyed(user).deliver_now unless user.email.blank? or user.username.blank?
  end

end
