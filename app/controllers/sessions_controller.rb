class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    if logged_in?
      # Means our user is signed in. Add the authorization to the user
      begin
        auth = current_user.add_provider(auth_hash)
        notice = "You can now login using this #{auth_hash["provider"].capitalize} account"
      rescue AuthTaken => e
        notice = e.message
        cookies.delete :submit_after_session_create
      rescue AuthPreexisting => e
        notice = e.message
        # TODO - clean this up. This is to migrate over twitter users who had the previous read-only permissions
        if auth_hash["provider"] == 'twitter'
          auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
          unless auth.can :write
            auth.add_perm :write
            auth.save
          end
        end
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
        @redirect_to = "/#{auth.user.username}/list"
      else
        @redirect_to = '/pick_a_url'
      end
      render "redirect"
    end
  end

  def failure
    cookies.delete :session_create_redirect
    cookies.delete :submit_after_session_create
    render :text => "Sorry, but you didn't allow access to our app!"
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Signed out!"
  end

end
