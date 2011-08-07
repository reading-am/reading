class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by_provider_and_uid(auth["provider"], auth["uid"])
    cookies.permanent[:auth_token] = user.auth_token
    if user.username
      redirect_to "/#{user.username}", :notice => "Signed in!"
    else
      redirect_to '/pick_a_url'
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Signed out!"
  end
end
