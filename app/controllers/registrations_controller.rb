# via: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
# and: https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb#L39
class RegistrationsController < Devise::RegistrationsController

  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :username, :email, :password, :password_confirmation, :remember_me)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      attrs = [:username, :email, :name, :first_name, :last_name,
               :password, :password_confirmation,
               :remember_me, :mail_digest, :email_when_followed, :email_when_mentioned,
               :location, :bio, :link, :phone, :urls, :description, :avatar]
      attrs << :current_password if change_requires_password

      if resource.roles? :admin
        attrs << {roles: [], access: []}
      end

      u.permit(attrs)
    end
  end

  def change_requires_password
    email_changed = !resource.email.blank? && resource_params.has_key?(:email) && resource.email != resource_params[:email]
    password_changed = !resource_params[:password].blank?

    email_changed || password_changed
  end

  def after_update_path_for(resource)
    case resource
    when :user, User
      edit_user_registration_path
    else
      super
    end
  end

  public

  # This is taken directly from Devise 2.1.2: https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb#L39
  # The only modifications are:
  #   * Use update_without_password if email and password are unchanged
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if resource.send("update_with#{change_requires_password ? '' : 'out'}_password", account_update_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def almost_ready
    redirect_to root_url && return unless signed_in?

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if !resource.username.blank? and !resource.email.blank? and resource.has_pass?
      redirect_to "/settings/info" and return
    end
  end

  def almost_ready_update
    redirect_to root_url && return unless signed_in?

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.send("update_with#{change_requires_password ? '' : 'out'}_password", account_update_params)
      sign_in resource_name, resource, bypass: true
      redirect_to("/#{resource.username}/list", notice: 'User was successfully updated.')
    else
      clean_up_passwords resource
      render :almost_ready
    end
  end

end
