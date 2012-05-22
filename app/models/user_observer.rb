class UserObserver < ActiveRecord::Observer

  def before_save(user)
    if Rails.env == 'production' && !user.username.blank? && user.username_was.blank?
      tweet = "Everyone welcome #{user.username}! http://#{DOMAIN}/#{user.username}"
      Twitter::Client.new(:oauth_token => "***REMOVED***", :oauth_token_secret => "***REMOVED***").delay.update tweet rescue nil
    end
  end

end
