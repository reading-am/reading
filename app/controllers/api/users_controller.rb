# encoding: utf-8
class Api::UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    if params[:page_id]
      @page = Page.find(params[:page_id])
      @users = User.who_posted_to(@page)
      # this is disabled until we get more users on the site
      # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }
    end

    respond_to do |format|
      format.json { render :json => {
        :meta => {
          :status => 200,
          :msg => 'OK'
        },
        :response => {
          :users => @users.collect { |user|
            obj = user.simple_obj
            cur_post = user.posts.where('page_id = ?', @page.id).last
            before =  user.posts.where('id < ?', cur_post.id).first
            after = user.posts.where('id > ?', cur_post.id).last
            obj[:posts] = [
              before.blank? ? {:type => 'Post', :id => -1} : before.simple_obj,
              after.blank? ? {:type => 'Post', :id => -1} : after.simple_obj
            ]
            obj
          }
        }
      }, :callback => params[:callback] }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.json { render :json => {
        :meta => {
          :status => 200,
          :msg => 'OK'
        },
        :response => {
          :user => @user.simple_obj
        }
      }, :callback => params[:callback] }
    end
  end

end
