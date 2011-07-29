class PostsController < ApplicationController
  # GET /posts
  # GET /posts.xml
  def index
    if params[:username]
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
    @user = User.find_by_token(params[:token])
    @post = Post.new
    @post.user = @user
    @post.url = params[:url]
    @post.title = params[:title]

    respond_to do |format|
      if @post.save
        # move this to a config file
        api_token = '4acf4be53765ca92e1aca994811761'
        client = HipChat::Client.new(api_token)
        notify_users = true
        message = render_to_string :partial => 'posts/hipchat_message.html.erb'
        client['Test'].send('Reading.am', "#{message}", notify_users)

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
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
end
