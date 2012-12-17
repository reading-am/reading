# via: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
# and: https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb#L39
class RegistrationsController < Devise::RegistrationsController

  # This is taken directly from Devise 2.1.2: https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb#L39
  # The only modifications are:
  #   * Use update_without_password if email and password are unchanged
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    email_changed = resource_params.has_key?(:email) && resource.email != resource_params[:email]
    password_changed = !resource_params[:password].blank?

    if resource.send("update_with#{email_changed || password_changed ? '' : 'out'}_password", resource_params)
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def almost_ready
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if !signed_in?
      redirect_to root_url and return
    elsif !resource.username.blank? and !resource.email.blank? and resource.has_pass?
      redirect_to "/settings/info" and return
    end
  end

  def almost_ready_update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    email_changed = resource_params.has_key?(:email) && resource.email != resource_params[:email]
    password_changed = !resource_params[:password].blank?

    if resource.send("update_with#{email_changed || password_changed ? '' : 'out'}_password", resource_params)
      sign_in resource_name, resource, :bypass => true
      redirect_to("/#{resource.username}/list", :notice => 'User was successfully updated.')
    else
      clean_up_passwords resource
      render :almost_ready
    end

  end

  protected

  def after_update_path_for(resource)
    case resource
    when :user, User
      edit_user_registration_path
    else
      super
    end
  end
end
