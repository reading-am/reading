class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
    @user = User.find_by_username(params[:username])
    # double bang converts to boolean http://rubyquicktips.com/post/583755021/convert-anything-to-boolean
    result = !!current_user.follow!(@user)

    if result && @user.wants_mail && @user.email
      UserMailer.delay.new_follower(@user, current_user)
    end

    respond_to do |format|
      format.html { render :text => result }
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end

  def destroy
    @user = User.find_by_username(params[:username])
    result = !!current_user.unfollow!(@user)
    respond_to do |format|
      format.html { render :text => result }
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end
end
