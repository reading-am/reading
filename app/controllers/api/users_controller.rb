# encoding: utf-8
class Api::UsersController < Api::APIController

  def index
    # list users who have visited a page
    # pages/1/users
    @page = Page.find(params[:page_id])
    @users = User.who_posted_to(@page)
    # this is disabled until we get more users on the site
    # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }

    if params[:user_ids]
      @users = @users.where(id: params[:user_ids])
    end

    @users = @users.limit(params[:limit])
                   .offset(params[:offset])
                   .order("created_at DESC")

    respond_to do |format|
      format.json { render_json :users => @users.collect { |user| user.simple_obj } }
    end
  end
  add_transaction_tracer :index

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
  add_transaction_tracer :show

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
  add_transaction_tracer :expats

  def recommended
    @users = User.where("posts_count > ?", 300).order("followers_count DESC").limit(20)

    respond_to do |format|
      format.json { render_json :users => @users.collect{ |u| u.simple_obj } }
    end
  end
  add_transaction_tracer :recommended

  def search
    search = User.search do fulltext params[:q] end
    @users = search.results

    respond_to do |format|
      format.json { render_json :users => @users.collect{ |u| u.simple_obj } }
    end
  end
  add_transaction_tracer :search

  def count
    if current_user.roles? :admin
      respond_to do |format|
        format.json { render_json :total_users => User.count }
      end
    else
      show_404
    end
  end
  add_transaction_tracer :count

end
