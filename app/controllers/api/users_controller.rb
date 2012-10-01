# encoding: utf-8
class Api::UsersController < Api::APIController
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
      format.json { render_json :users => @users.collect { |user| user.simple_obj } }
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

end
