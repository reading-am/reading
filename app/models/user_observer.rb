class UserObserver < ActiveRecord::Observer

  def before_save(user)
    return unless new_user?(user)

    PusherJob.perform_later 'create', user
    UserMailer.welcome(user).deliver_later

    # Tweet to ReadingArrivals
    return unless Rails.env.production?
    tweet = "Everyone welcome #{user.username}! #{ROOT_URL}/#{user.username}"
    TweetJob.perform_later ENV['READING_ARRIVALS_TOKEN'],
                           ENV['READING_ARRIVALS_SECRET'],
                           tweet
  end

  def after_update(user)
    PusherJob.perform_later 'update', user
  end

  def after_destroy(user)
    PusherJob.perform_later 'destroy', user

    # Don't perform any more callbacks if this was an aborted registration
    return if aborted_registration?(user)

    # This can't be delayed because user won't exist by the time it's processed
    UserMailer.destroyed(user).deliver_now
  end

  private

  def new_user?(user)
    (
      user.username_was.blank? ||
      (user.email_was.blank? && !user.joined_before_email?)
    ) &&
      user.username.present? && user.email.present?
  end

  def aborted_registration?(user)
    user.email.blank? || user.username.blank?
  end
end
