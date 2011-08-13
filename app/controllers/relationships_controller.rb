class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
    @user = User.find_by_username(params[:username])
    current_user.follow!(@user)
    redirect_to @user
  end

  def destroy
    @user = User.find_by_username(params[:username])
    current_user.unfollow!(@user)
    redirect_to @user
  end
end
