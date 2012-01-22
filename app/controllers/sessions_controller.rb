class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']

    if logged_in?
      # Means our user is signed in. Add the authorization to the user
      begin
        auth = current_user.add_provider(auth_hash)
        message = "AuthAdded"
      rescue AuthTaken => e
        message = "AuthTaken"
      rescue AuthPreexisting => e
        message = "AuthPreexisting"
        # TODO - clean this up. This is to migrate over twitter users who had the previous read-only permissions
        if auth_hash["provider"] == 'twitter'
          auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
          unless auth.can :write
            auth.add_perm :write
            auth.save
          end
        end
      end
    else
      # Log him in or sign him up
      auth = Authorization.find_or_create(auth_hash)
      cookies.permanent[:auth_token] = auth.user.auth_token
      message = "AuthLoginCreate"
    end

    render "redirect", :locals => {:method => "success", :message => message, :auth_hash => auth_hash}, :layout => false
  end

  def failure
    render "redirect", :locals => {:method => "failure"}, :layout => false
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Signed out!"
  end

end
