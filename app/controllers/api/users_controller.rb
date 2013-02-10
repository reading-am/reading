# encoding: utf-8
class Api::UsersController < Api::APIController

  def index
    if params[:user_id]
      # list followers or following of a user
      # users/1/followers
      # users/1/following
      @user = User.find(params[:user_id])
      @users = @user.send(params[:type])
    elsif params[:page_id]
      # list users who have visited a page
      # pages/1/users
      @page = Page.find(params[:page_id])
      @users = User.who_posted_to(@page)
      # this is disabled until we get more users on the site
      # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }
    else
      @users = User.order("created_at DESC")
                   .paginate(:page => params[:page])
    end

    respond_to do |format|
      format.json { render_json :users => @users.collect { |user| user.simple_obj } }
    end
  end

  def show
    if params[:user_id]
      # check if a user is following or follows another user
      # users/1/followers/2
      # users/2/following/1
      @base_user = User.find(params[:user_id])
      @user = @base_user.send(params[:type]).where(:id => params[:id]).first
    else
      # show user
      # users/1
      @user = User.find(params[:id])
    end
    if !@user.blank?
      respond_to do |format|
        format.json { render_json :user => @user.simple_obj }
      end
    else
      show_404
    end
  end

  def expats
    @user = User.find(params[:id])

    @users = []
    @user.authorizations.each do |a|
      @users |= a.following
    end
    # don't include the user being queried on
    @users.delete @user

    respond_to do |format|
      format.json { render_json :users => @users.collect{ |u| u.simple_obj } }
    end
  end

  def recommended
    @users = User.where("posts_count > ?", 300).order("followers_count DESC").limit(20)

    respond_to do |format|
      format.json { render_json :users => @users.collect{ |u| u.simple_obj } }
    end
  end

  def search
    search = User.search do fulltext params[:q] end
    @users = search.results

    respond_to do |format|
      format.json { render_json :users => @users.collect{ |u| u.simple_obj } }
    end
  end

  def count
    if current_user.roles? :admin
      respond_to do |format|
        format.json { render_json :total_users => User.count }
      end
    else
      show_404
    end
  end

  def me
    respond_to do |format|
      format.json { render_json current_user.to_json }
    end
  end

end
