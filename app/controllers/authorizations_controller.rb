class AuthorizationsController < ApplicationController
  # DELETE /authorizations/1
  # DELETE /authorizations/1.xml
  def destroy
    @authorization = Authorization.find(params[:id])
    if !logged_in?
      redirect_to "/"
    elsif @authorization.user != current_user
      redirect_to "/#{current_user.username}"
    end
    @authorization.destroy

    respond_to do |format|
      format.html { redirect_to("/#{current_user.username}/settings") }
      format.xml  { head :ok }
    end
  end
end
