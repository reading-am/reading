# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :followingers, :delete_cookies, :tagalong, :find_people]

  # GET /users/1
  # GET /users/1.xml
  def show
    if params[:username] == 'everybody'
      @posts  = Post.order("created_at DESC")
                    .includes([:user, :page, {:referrer_post => :user}])
                    .paginate(:page => params[:page])
      @channels = 'everybody'
    else
      @user = params[:username] ?
        User.find_by_username(params[:username]) :
        User.fetch(params[:id])
      if !@user then not_found end

      @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})" << " on ✌ Reading"

      if params[:type] == 'list'
        @posts = @user.feed.paginate(:page => params[:page])
        @channels = @user.following.map { |user| user.username }
        # add the user to the channels since it's not in .following()
        @channels.push @user.username
      else
        @posts = @user.posts.order("created_at DESC").paginate(:page => params[:page])
        @channels = @user.username
      end
    end

    respond_to do |format|
      format.html { render 'posts/index' }
      format.xml  { render 'posts/index', :xml => @posts }
      format.rss  { render 'posts/index' }
    end
  end

  def tumblr
    @user = params[:username] ?
      User.find_by_username(params[:username]) :
      User.fetch(params[:id])
    if !@user then not_found end

    @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})"
    @posts = @user.posts.order("created_at DESC").paginate(:page => params[:page]).map do |p|
      case p.page.medium
      when :text
        {'type' => 'text', 'title' => p.page.title, 'body' => p.page.excerpt}
      when :audio
        {'type' => 'text', 'title' => p.page.title, 'body' => p.page.excerpt}
      when :video
        {'type' => 'video', 'title' => p.page.title, 'body' => p.page.excerpt, 'player' => [500,400,250].map{|w| {'width'=>w,'embed_code'=>p.page.embed}}}
      when :image
        {'type' => 'photo', 'title' => p.page.title, 'body' => p.page.excerpt, 'photos' => [{'alt_sizes' => [500, 400, 250, 100].map{|w| {'width'=>w,'url'=>p.page.image}}}]}
      end
    end

    template = Tuml::Template.new(File.open("/Users/leppert/Desktop/default_template.html", "rb").read)
    page = Tuml::IndexPage.new('title' => @page_title, 'description' => @user.bio, 'posts' => @posts)

    respond_to do |format|
      format.html { render :text => template.render(page) }
    end
  end

  def settings
    redirect_to "/settings/info"
  end

  def followingers
    @user = User.find_by_username(params[:username])
    @users = (params[:type] == 'followers') ? @user.followers : @user.following
  end

  def hooks
    @user = current_user
    @new_hook = Hook.new
    @hooks = @user.hooks

    respond_to do |format|
      format.html { render 'hooks/index' }
      format.xml  { render 'hooks/index', :xml => @hooks }
      format.rss  { render 'hooks/index' }
    end
  end

  def delete_cookies
    cookies.each do |k, v| cookies.delete k end
    redirect_to '/'
  end

  def export
    user = User.find_by_username(params[:username])
    if user == current_user
      respond_to do |format|
        format.csv { render 'posts/export', :layout => false, :locals => {:posts => user.posts} }
      end
    else
      show_404
    end
  end

  def extras
    @user = current_user
    @post_email = MailPipe::encode_mail_recipient('post', current_user, current_user)
  end

  def tagalong
    @user = User.fetch(params[:user_id])

    case params[:dir]
    when "next"
      @post = @user.posts.where("id > ?", params[:post_id]).order("id ASC").limit(1).first
    when "prev"
      @post = @user.posts.where("id < ?", params[:post_id]).order("id DESC").limit(1).first
    end

    if @post.blank?
      redirect_to "/#{@user.username}", :notice => "You've reached the end of #{@user.first_name}'s posts. Thanks for tagging along!"
    else
      redirect_to @post.wrapped_url
    end
  end

  def find_people
  end
end
