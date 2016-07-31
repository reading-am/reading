class AdminController < ApplicationController
  before_action :authenticate_user!, :check_for_admin_role

  private

  def check_for_admin_role
    show_404 unless current_user.roles? :admin
  end

  public

  def dashboard
    respond_to do |format|
      format.html { render :layout => 'backbone' }
      format.xml  { render :xml => @comment }
    end
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Sign-in-as-another-user-if-you-are-an-admin
  def become
    sign_in(:user, User.find_by_username!(params[:username]))
    redirect_to root_url
  end

end
