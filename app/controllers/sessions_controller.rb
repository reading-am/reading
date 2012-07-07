# encoding: utf-8
class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
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
        username = auth_hash["info"]["nickname"]
        username = username.blank? ? nil : username.gsub(/[^A-Z0-9_]/i, '')
        user = User.create(
          :name       => auth_hash["info"]["name"],
          :email      => auth_hash["info"]["email"],
          # check to make sure a user doesn't already have that nickname
          :username   => (username.blank? or User.find_by_username(username)) ? nil : username,
          :first_name => auth_hash["info"]["first_name"],
          :last_name  => auth_hash["info"]["last_name"],
          :location   => auth_hash["info"]["location"],
          :description=> auth_hash["info"]["description"],
          :image      => auth_hash["info"]["image"],
          :phone      => auth_hash["info"]["phone"],
          :urls       => auth_hash["info"]["urls"]
        )
        # account for facebook usernames with periods and the like
        unless user.errors.messages[:username].nil?
          user.username = nil
          user.save
        end
        # account for bad email addresses coming from provider
        unless user.errors.messages[:email].nil?
          user.email = nil
          user.save
        end
        auth = Authorization.create(
          :user       => user,
          :provider   => auth_hash["provider"],
          :uid        => auth_hash["uid"],
          :token      => auth_hash["credentials"]["token"],
          :secret     => auth_hash["credentials"]["secret"],
          :expires_at => auth_hash["credentials"]["expires_at"],
          :info       => auth_hash['extra']['raw_info'].nil? ? nil : auth_hash['extra']['raw_info'].to_json
        )

        # Auto-follow everyone from their social network
        auth.following.each do |u|
          user.follow!(u)
        end
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
