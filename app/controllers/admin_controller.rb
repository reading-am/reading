class AdminController < ApplicationController

  before_filter :check_for_admin_role

  private

  def check_for_admin_role
    show_404 unless current_user.roles? :admin
  end

  public

  def dashboard
    respond_to do |format|
      format.html { render :layout => 'bb' }
      format.xml  { render :xml => @comment }
    end
  end

end
