# via: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
class RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)
    email_changed = @user.email != params[:user][:email]
    password_changed = !params[:user][:password].empty?

    successfully_updated = if email_changed or password_changed
      @user.update_with_password(params[:user])
    else
      @user.update_without_password(params[:user])
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
    end
    redirect_to edit_user_registration_path
  end
end
