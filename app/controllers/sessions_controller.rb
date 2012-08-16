# encoding: utf-8
class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']

    # mapped so as to avoid problems with variables starting with numbers
    if auth_hash.provider == '37signals'
      auth_hash.provider = 'tssignals'
    end

    if logged_in?
      # Means our user is signed in. Add the authorization to the user
      begin
        auth = current_user.add_provider(auth_hash)
        status = "AuthAdded"
      rescue AuthError => e
        status = e.message
        auth = e.auth
      end
    else
      # Log him in or sign him up
      if auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
        # fill in any changed info
        ["token","secret","expires_at"].each do |prop|
          auth[prop] = auth_hash["credentials"][prop] || auth[prop]
        end
        auth.save
      else
        # NEW USER
        username = auth_hash["info"]["nickname"]
        username = username.blank? ? nil : username.gsub(/[^A-Z0-9_]/i, '')
        username = username.blank? ? nil : username

        user = User.create(
          :username   => username,
          :name       => auth_hash["info"]["name"],
          :email      => auth_hash["info"]["email"],
          :first_name => auth_hash["info"]["first_name"],
          :last_name  => auth_hash["info"]["last_name"],
          :location   => auth_hash["info"]["location"],
          :description=> auth_hash["info"]["description"],
          :image      => auth_hash["info"]["image"],
          :phone      => auth_hash["info"]["phone"],
          :urls       => auth_hash["info"]["urls"]
        )

        # account for taken usernames and facebook usernames with periods and the like
        user.username = nil if !user.errors.messages[:username].blank?
        # account for bad email addresses coming from provider
        user.email = nil if !user.errors.messages[:email].blank?
        user.save if user.changed?

        auth = Authorization.create(
          :user       => user,
          :provider   => auth_hash["provider"],
          :uid        => auth_hash["uid"],
          :token      => auth_hash["credentials"]["token"],
          :refresh_token => auth_hash["credentials"]["refresh_token"],
          :secret     => auth_hash["credentials"]["secret"],
          :expires_at => auth_hash["credentials"]["expires_at"],
          :info       => auth_hash['extra']['raw_info'].nil? ? nil : auth_hash['extra']['raw_info'].to_json
        )

        # Auto-follow everyone from their social network
        #auth.following.each do |u|
          #user.follow!(u)
        #end
      end

      cookies.permanent[:auth_token] = auth.user.auth_token
      status = "AuthLoginCreate"
    end

    data = {:status => status, :authResponse => auth_hash, :auth => auth.nil? ? nil : auth.simple_obj}
    if !params[:return_type].nil? and params[:return_type] == 'json'
      render :text => data.to_json
    else
      render "redirect", :locals => data, :layout => false
    end
  end

  def failure
    data = {:status => "AuthFailure", :authResponse => nil, :auth => nil}
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
