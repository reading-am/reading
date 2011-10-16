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
        if !params[:title].nil?
          @post.page.title = params[:title]
        else
          # If you've submitted a new page but you didn't submit a title,
          # curl the title from the page.
          c = Curl::Easy.perform @post.page.url
          doc = Nokogiri::HTML(c.body_str)
          title = doc.search('title').first
          @post.page.title = title.nil? ? '' : doc.search('title').first.text
        end
      end
      @post.referrer_post ||= Post.find_by_id(params[:referrer_id])
    else
      @post = duplicate
      if !params[:yn].nil?
        @post.yn = params[:yn]
      end
      update = @post.changed?
    end

    respond_to do |format|
      # if it's a duplicate and we changed something, it'll be aliased to @post and saved in the second part of the conditional
      if (duplicate && !duplicate.changed?) or @post.save
        if !duplicate or update
          # Websockets
          json = render_to_string :partial => 'posts/post.json.erb', :locals => {:post => @post}
          event = update ? 'update_obj' : 'new_obj';
          Pusher['everybody'].trigger_async(event, json)
          Pusher[@post.user.username].trigger_async(event, json)

          @post.user.hooks.each do |hook|
            # TODO I'd like to make this a helper of some sort
            case hook.provider
            when 'hipchat'
              client = HipChat::Client.new(hook.params['token'])
              notify_users = !update # only notify if this is not a post update
              message = render_to_string :partial => "posts/hipchat_#{update ? 'update' : 'new'}.html.erb", :locals => {:post => @post}
              client[hook.params['room']].send('Reading.am', "#{message}", notify_users)
            when 'campfire'
              campfire = Tinder::Campfire.new hook.params['subdomain'], :token => hook.params['token']
              room = campfire.find_or_create_room_by_name(hook.params['room'])
              if !room.nil?
                room.speak render_to_string :partial => "posts/campfire_#{update ? 'update' : 'new'}.txt.erb"
              end
            when 'opengraph'
              url = "https://graph.facebook.com/me/reading-am:#{@post.domain.imperative}"
              EventMachine::HttpRequest.new(url).post :body => {
                :access_token => hook.params['access_token'],
                #gsub for testing since Facebook doesn't like my localhost
                :website => @post.wrapped_url.gsub('0.0.0.0:3000', 'reading.am')
              }
            when 'url'
              data = { :post => {
                :id             => "#{@post.id}",
                :yn             => @post.yn,
                :title          => @post.page.title,
                :url            => @post.page.url,
                :wrapped_url    => @post.wrapped_url,
                :user => {
                  :id           => "#{@post.user.id}",
                  :username     => @post.user.username,
                  :display_name => @post.user.display_name
                },
                :referrer_post => {
                  :id           => !@post.referrer_post.nil? ? "#{@post.referrer_post.id}" : '',
                  :user => {
                    :id         => !@post.referrer_post.nil? ? "#{@post.referrer_post.user.id}" : '',
                    :username   => !@post.referrer_post.nil? ? @post.referrer_post.user.username : '',
                    :display_name => !@post.referrer_post.nil? ? @post.referrer_post.user.display_name : ''
                  }
                }
              }}

              url = hook.params['url']
              if url[0, 4] != "http" then url = "http://#{url}" end
              http = EventMachine::HttpRequest.new(url)

              if hook.params['method'] == 'get'
                addr = Addressable::URI.new 
                addr.query_values = data # this chokes unless you wrap ints in quotes per: http://stackoverflow.com/questions/3765834/cant-convert-fixnum-to-string-during-rake-dbcreate
                http.get :query => addr.query
              else
                http.post :body => data
              end
            end
          end
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
    if @ref = Post.find(@referrer_id)
      @og_props = {
        :title => "✌ #{@ref.page.title}",
        :image => "http://#{@ref.page.domain.name}/apple-touch-icon.png",
        :description => false
      }
    end
  end

end
