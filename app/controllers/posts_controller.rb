# encoding: utf-8
class PostsController < ApplicationController
  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.order("created_at DESC").limit(75)
    @channels = 'everybody'
    respond_to do |format|
      format.html { render 'home/index' }
      format.rss  { render 'posts/index' }
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
    @post       = Post.new
    @post.user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @post.page  = Page.find_by_url(params[:url]) || Page.new(:url => params[:url], :title => params[:title])
    @post.yn    = params[:yn]
    # A post is a duplicate if it's the exact same page and within 1hr of the last post
    duplicate = (!@post.user.posts.first.nil? and @post.page == @post.user.posts.first.page and (Time.now - @post.user.posts.first.created_at < 60*60)) ? @post.user.posts.first : false;
    # TODO - clean up these conditionals for duplicates and the same in the respond_to
    if !duplicate
      if @post.page.new_record?
        @post.page.title = !params[:title].nil? ? params[:title] : @post.page.remote_title
      end
      @post.referrer_post ||= Post.find_by_id(params[:referrer_id])
    else
      @post     = duplicate
      @post.yn  = params[:yn] if !params[:yn].nil?
      is_update = @post.changed?
    end

    respond_to do |format|
      # if it's a duplicate and we changed something, it'll be aliased to @post and saved in the second part of the conditional
      if (duplicate && !duplicate.changed?) or @post.save
        if !duplicate or is_update
          event = is_update ? :update : :new
          # We treat Pusher just like any other hook except that we don't store it
          # with the user so we go ahead and construct one here
          Hook.new({:provider => 'pusher'}).run(@post, event)
          @post.user.hooks.each do |hook| hook.run(@post, event) end
        end
        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
        format.json { render :json => {:meta => {:status => 200, :msg => 'OK'}}, :callback => params[:callback] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json { render :json => {:meta => {:status => 400, :msg => "Bad Request #{@post.errors.to_yaml}"}}, :callback => params[:callback] }
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

  def visit
    @token = if params[:token] then params[:token] elsif logged_in? then current_user.token else '' end
    @referrer_id = params[:id] ? Base58.decode(params[:id]) : 0
    @ref = Post.find(@referrer_id)
    if @ref
      if !params[:url] # shortener uses this
        redirect_to @ref.page.url
      else
        @og_props = {
          :title => "✌ #{@ref.page.title || @ref.page.url}",
          :image => "http://#{@ref.page.domain.name}/apple-touch-icon.png",
          :description => false
        }
      end
    end
  end

end
