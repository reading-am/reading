# encoding: utf-8
class PostsController < ApplicationController
  before_filter :check_login

  # GET /posts
  # GET /posts.xml
  def index
    # for JSONP requests
    if !params[:_method].blank?
      case params[:_method]
      when 'POST'
        return create()
      end
    end

    @posts =  Post.order("created_at DESC")
                  .includes([:user, :page, :domain, {:referrer_post => :user}])
                  .paginate(:page => params[:page])
    @channels = 'everybody'
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    # for JSONP requests
    if !params[:_method].blank?
      case params[:_method]
      when 'PUT'
        return update()
      when 'DELETE'
        return destroy()
      end
    end

    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => {
        :meta => {
          :status => 200,
          :msg => 'OK'
        },
        :response => {
          :post => @post.simple_obj
        }
      },:callback => params[:callback] }
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
    url   = params[:model][:url]
    title = params[:model][:title] == 'null' ? nil : params[:model][:title]
    yn    = params[:model][:yn]
    ref_id= params[:model][:referrer_id]

    @post       = Post.new
    @post.user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @post.page  = Page.find_by_url(url) || Page.new(:url => url, :title => title)
    @post.yn    = params[:yn]

    if !@post.user.blank?
      # A post is a duplicate if it's the exact same page and within 1hr of the last post
      duplicate = (!@post.user.posts.first.nil? and @post.page == @post.user.posts.first.page and (Time.now - @post.user.posts.first.created_at < 60*60)) ? @post.user.posts.first : false;
      # TODO - clean up these conditionals for duplicates and the same in the respond_to
      if !duplicate
        event = :new
        if @post.page.new_record?
          @post.page.title = !title.nil? ? title : @post.page.remote_title
        end
        @post.referrer_post ||= Post.find_by_id(ref_id)
      else
        @post = duplicate
        @post.yn = yn if !yn.nil?
        if !@post.changed?
          event = :duplicate
          @post.touch
        else
          event = @post.yn ? :yep : :nope
        end
      end
    end

    respond_to do |format|
      if (!@post.new_record? and !@post.changed?) or @post.save
        # We treat Pusher just like any other hook except that we don't store it
        # with the user so we go ahead and construct one here
        Hook.new({:provider => 'pusher', :events => [:new,:yep,:nope]}).run(@post, event)
        @post.user.hooks.each do |hook| hook.run(@post, event) end

        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
        format.json { render :json => {
          :meta => {
            :status => 200,
            :msg => 'OK'
          },
          :response => {
            :post => @post.simple_obj,
            :readers => User.who_posted_to(@post.page).collect { |user|
              if user != @post.user # don't show the person posting
                obj = user.simple_obj
                cur_post = user.posts.where('page_id = ?', @post.page.id).last
                before =  user.posts.where('id < ?', cur_post.id).first
                after = user.posts.where('id > ?', cur_post.id).last
                obj[:posts] = {
                  :before => before.blank? ? nil : before.simple_obj,
                  :after => after.blank? ? nil : after.simple_obj
                }
                obj
              end
            }.compact
            # this is disabled until we get more users on the site
            # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }
          }
        }, :callback => params[:callback] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        if @post.user.blank? # TODO clean up this auth hack. Ugh.
          format.json { render :json => {:meta => {:status => 403, :msg => "Forbidden"}}, :callback => params[:callback] }
        else
          format.json { render :json => {:meta => {:status => 400, :msg => "Bad Request #{@post.errors.to_yaml}"}}, :callback => params[:callback] }
        end
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    user = params[:token] ? User.find_by_token(params[:token]) : current_user

    if allowed = (user == @post.user) and !params[:model].nil?
      params[:model][:yn] = nil if !params[:model][:yn].nil? and params[:model][:yn] == 'null'
      @post.yn = params[:model][:yn]
    end

    respond_to do |format|
      if allowed and ((changed = @post.changed? and @post.save) or @post.touch)
        if changed
          # We treat Pusher just like any other hook except that we don't store it
          # with the user so we go ahead and construct one here
          event = @post.yn ? :yep : :nope
          Hook.new({:provider => 'pusher', :events => [:new,:yep,:nope]}).run(@post, event)
          @post.user.hooks.each do |hook| hook.run(@post, event) end
        end

        format.html { redirect_to(@post, :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :json => {
          :meta => {
            :status => 200,
            :msg => 'OK'
          },
          :response => {}
        }, :callback => params[:callback] }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        if !allowed # TODO clean up this auth hack. Ugh.
          format.json { render :json => {:meta => {:status => 403, :msg => "Forbidden"}}, :callback => params[:callback] }
        else
          format.json { render :json => {:meta => {:status => 400, :msg => "Bad Request #{@post.errors.to_yaml}"}}, :callback => params[:callback] }
        end
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

  # A note about schema
  # The original idea was that the referrer_id didn't
  # have to dictate the :url param - that way we could
  # eventually mix and match 'because of' with different
  # end results. Otherwise we could just forward straight
  # without the intermediate page.
  # I've considered doing this with the URL shortener,
  # but Rails make sharing code between controller methods
  # a pain in the ass
  def visit
    # this is disabled while I look for some funny business
    #@token = if params[:token] then params[:token] elsif logged_in? then current_user.token else '' end
    @token = if params[:token] == '-' then params[:token] elsif logged_in? then current_user.token else '' end
    @referrer_id = 0 # default

    if !params[:id]
      # Pass through and post any domain, even
      # if it's not already in the system
      # schema: reading.am/http://example.com
    else
      @referrer_id = Base58.decode(params[:id])
      @ref = Post.find(@referrer_id)

      if !params[:url]
        # Post from a referrer id only
        # Currently only used for the shortener
        # schema: ing.am/p/xHjsl
        redirect_to @ref.wrapped_url
      else
        # Post through the classic JS method
        # Facebook hits this page to grab info
        # for the timeline
        @page_title = "✌ #{@ref.page.display_title}"
        @og_props = {
          :title => @page_title,
          :image => "http://#{@ref.page.domain.name}/apple-touch-icon.png",
          :description => false
        }
      end
    end
  end

end
