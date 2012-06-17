# encoding: utf-8
class Api::UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @users = @user.send(params[:type])
    elsif params[:page_id]
      @page = Page.find(params[:page_id])
      @users = User.who_posted_to(@page)
      # this is disabled until we get more users on the site
      # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }
    else
      @users = User.order("created_at DESC")
                   .paginate(:page => params[:page])
    end

    respond_to do |format|
      format.json { render_json({
          :users => @users.collect { |user|
            obj = user.simple_obj

            if !@page.blank?
              cur_post = user.posts.where('page_id = ?', @page.id).last
              before =  user.posts.where('id < ?', cur_post.id).first
              after = user.posts.where('id > ?', cur_post.id).last
              obj[:posts] = [
                before.blank? ? {:type => 'Post', :id => -1} : before.simple_obj,
                after.blank? ? {:type => 'Post', :id => -1} : after.simple_obj
              ]
            end

            obj
          }
        })
      }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.json { render_json :user => @user.simple_obj }
    end
  end

  def following
    @user = User.find(params[:user_id])
    auth = @user.authorizations
                .where(:provider => params[:provider])
                .order("created_at ASC")
                .first
    respond_to do |format|
      format.json { render_json :users => auth.following.collect{ |u| u.simple_obj } }
    end
  end

end
