module MailHelper

  def current_user
    @current_user ||= User.new
  end

  def logged_in?
    false
  end

end
