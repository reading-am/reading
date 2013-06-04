# encoding: utf-8
class Api::UsersController < Api::APIController

  def index
    if params[:user_id]
      # list followers or following of a user
      # users/1/followers
      # users/1/following
      @user = User.fetch(params[:user_id])
      @users = @user.send(params[:type])
    elsif params[:page_id]
      # list users who have visited a page
      # pages/1/users
      @page = Page.fetch(params[:page_id])
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
  add_transaction_tracer :index

  def show
    if params[:user_id]
      # check if a user is following or follows another user
      # users/1/followers/2
      # users/2/following/1
      @base_user = User.fetch(params[:user_id])
      @user = @base_user.send(params[:type]).where(:id => params[:id]).first
    else
      # show user
      # users/1
      @user = User.fetch(params[:id])
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
    @user = User.fetch(params[:id])

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

  def presence
    event = ActiveSupport::JSON.decode(request.raw_post)['events'].first
    if (event['channel'] =~ /^users\.[0-9]*\.feed$/) == 0 \
      and ['channel_occupied','channel_vacated'].include? event['name']
      user = User.fetch(event['channel'].split('.')[1])
      user.feed_present = (event['name'] == 'channel_occupied')
      user.save
    end
    respond_to do |format|
      format.html {head :ok}
    end
  end
  add_transaction_tracer :presence

end
