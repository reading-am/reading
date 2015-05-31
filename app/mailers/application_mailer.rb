class ApplicationMailer < ActionMailer::Base
  include RenderApi
  default from: "Reading <mailman@#{ROOT_DOMAIN}>"

  ## HELPERS
  # these used to be in a separate file but they were being
  # included with the normal app controller
  helper_method :current_user,
                :signed_in?,
                :user_signed_in?,
                :render_api

  def current_user
    @current_user ||= User.new
  end

  def signed_in?
    false
  end

  def user_signed_in?
    false
  end
end
