# encoding: utf-8
class OmniauthController < Devise::OmniauthCallbacksController
  # via: https://github.com/plataformatec/devise/wiki/Omniauthable,-sign-out-action-and-rememberable
  include Devise::Controllers::Rememberable

  # Devise sends all providers to different methods
  # This globs them up and sends them to create()
  def action_missing(*args)
    create
  end

  def create
    auth_hash = request.env['omniauth.auth']

    # Log him in or sign him up
    if auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"].to_s)
      # fill in any changed info
      ["token","secret","expires_at"].each do |prop|
        auth.attributes = {prop => auth_hash["credentials"][prop] || auth[prop]}
      end
      auth.save
      status = !signed_in? ? 'AuthLogin' : (auth.user_id == current_user.id) ? 'AuthPreexisting' : 'AuthTaken'
    else
      if signed_in?
        user = current_user
        status = "AuthAdded"
      else
        # NEW USER
        user = User.new(User::transform_auth_hash(auth_hash))

        # skip required check on email and password
        user.email_required = user.password_required = false
        user.save

        # account for taken usernames and facebook usernames with periods and the like
        user.username = nil if !user.errors.messages[:username].blank?
        # account for bad email addresses coming from provider
        user.email = nil if !user.errors.messages[:email].blank?
        user.save

        status = "AuthRegister"
      end

      auth_params = Authorization::transform_auth_hash(auth_hash)
      auth_params[:user] = user
      auth = Authorization.create auth_params

      # Auto-follow everyone from their social network
      #auth.following.each{|u| user.follow!(u)}
    end

    if ['AuthLogin','AuthRegister'].include? status
      sign_in auth.user
      remember_me auth.user
    end

    data = { status: status,
             authResponse: auth_hash,
             auth: auth.nil? ? nil : render_api(partial: 'authorizations/authorization', authorization: auth) }
    if !params[:return_type].nil? and params[:return_type] == 'json'
      render text: data.to_json
    else
      render "redirect", locals: data, layout: false
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

end
