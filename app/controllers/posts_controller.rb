class PostsController < ApplicationController
  # GET /posts
  # GET /posts.xml
  def index
    if params[:domain_name]
      @domain = Domain.find_by_name(params[:domain_name])
      @posts = @domain.posts.order('created_at DESC')
    elsif params[:username]
      @user = User.find_by_username(params[:username])
      @posts = @user.posts.order('created_at DESC')
    elsif logged_in?
      @posts = current_user.posts.order('created_at DESC')
    else
      @posts = Post.order('created_at DESC')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post         = Post.new
    @post.user    = User.find_by_token(params[:token])
    @post.url     = params[:url]
    @post.domain  = Domain.find_or_create_by_name(:name => URI.parse(@post.url).host)
    @post.title   = params[:title]

    respond_to do |format|
      if @post.save
        @post.user.hooks.each do |hook|
          # TODO I'd like to make this a helper of some sort
          if hook.provider == 'hipchat'
            client = HipChat::Client.new(hook.token)
            notify_users = true
            message = render_to_string :partial => 'posts/hipchat_message.html.erb'
            client[hook.action].send('Reading.am', "#{message}", notify_users)
          end
        end
        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
        format.json { render :json => {:meta => {:status => 200, :msg => 'OK'}}, :callback => params[:callback] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json { render :json => {:meta => {:status => 400, :msg => 'Bad Request'}}, :callback => params[:callback] }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to(@post, :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    if @post.user == current_user
      @post.destroy
    end

    respond_to do |format|
      format.html { redirect_to("/#{current_user.username}") }
      format.xml  { head :ok }
    end
  end
end
