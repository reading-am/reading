# NOTE
# You must restart the server for changes in this file to take effect
# since the classes is loaded in an initializer (config/devise.rb).
# Rendered views, however, will reload just fine.

class OmniauthFormsController < ApplicationController
  layout 'bare'

  def kippt
    @username_label = 'Kippt Email'
    @password_label = 'Kippt Password'
    @url = '/users/auth/kippt/callback'
    render :form
  end

  def instapaper
    # The redirect flow here is via: https://github.com/aereal/omniauth-xauth/blob/master/lib/omniauth/strategies/xauth.rb#L19
    if request.method == 'GET'
      @username_label = 'Instapaper Email or Username'
      @password_label = 'Instapaper Password'
      render :form
    else
      session['omniauth.xauth'] = { 'x_auth_mode' => 'client_auth', 'x_auth_username' => request['username'], 'x_auth_password' => request['password'] }
      redirect_to '/users/auth/instapaper/callback'
    end
  end

end
