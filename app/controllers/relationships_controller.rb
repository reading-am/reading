# encoding: utf-8
class RelationshipsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @user = User.fetch_by_username(params[:username])
    result = !!current_user.follow!(@user)

    respond_to do |format|
      format.html { render :text => result }
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end

  def destroy
    @user = User.fetch_by_username(params[:username])
    result = !!current_user.unfollow!(@user)

    respond_to do |format|
      format.html { render :text => result }
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end
end
