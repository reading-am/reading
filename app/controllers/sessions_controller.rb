class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    if logged_in?
      # Means our user is signed in. Add the authorization to the user
      begin
        auth = current_user.add_provider(auth_hash)
        notice = "You can now login using this #{auth_hash["provider"].capitalize} account"
      rescue Exception => e
        notice = e.message
      end

      if path = cookies[:session_create_redirect]
        cookies.delete :session_create_redirect
        if cookies[:submit_after_session_create]
          cookies[:submit_after_session_create] = cookies[:submit_after_session_create].sub(/(\[?account\]?":")new"/,'\1'+auth.uid+'"')
        end
      else
        path = "/#{current_user.username}/info"
      end
      redirect_to path, :notice => notice
    else
      # Log him in or sign him up
      auth = Authorization.find_or_create(auth_hash)
      cookies.permanent[:auth_token] = auth.user.auth_token
      # Create the session
      if auth.user.username
        redirect_to "/#{auth.user.username}/list", :notice => "Signed in!"
      else
        redirect_to '/pick_a_url'
      end
    end
  end

  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Signed out!"
  end

end
