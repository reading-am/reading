class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    if logged_in?
      # Means our user is signed in. Add the authorization to the user
      begin
        auth = current_user.add_provider(auth_hash)
        status = "AuthAdded"
      rescue AuthTaken => e
        status = "AuthTaken"
      rescue AuthPreexisting => e
        status = "AuthPreexisting"
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
      status = "AuthLoginCreate"
    end

    data = {:status => status, :authResponse => auth_hash}
    if !params[:return_type].nil? and params[:return_type] == 'json'
      render :text => data.to_json
    else
      render "redirect", :locals => data, :layout => false
    end
  end

  def failure
    data = {:status => "AuthFailure", :authResponse => nil}
    if !params[:return_type].nil? and params[:return_type] == 'json'
      render :text => data.to_json
    else
      render "redirect", :locals => data, :layout => false
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Signed out!"
  end

end
