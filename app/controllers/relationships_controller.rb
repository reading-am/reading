class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
    @user = User.find_by_username(params[:username])
    respond_to do |format|
      # double bang converts to boolean http://rubyquicktips.com/post/583755021/convert-anything-to-boolean
      result = !!current_user.follow!(@user)
      format.html { render :text => result }
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end

  def destroy
    @user = User.find_by_username(params[:username])
    respond_to do |format|
      result = !!current_user.unfollow!(@user)
      format.html { render :text => result }
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end
end
