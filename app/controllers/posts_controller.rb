class PostsController < ApplicationController
  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.order("created_at DESC").limit(75)
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
    # A post is a duplicate if it's the exact same page and within 30secs of the last post
    is_duplicate = (!@post.user.posts.first.nil? and @post.page == @post.user.posts.first.page and (Time.now - @post.user.posts.first.created_at < 30))
    # TODO - clean up these conditionals for duplicates and the same in the respond_to
    if !is_duplicate
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
    end

    respond_to do |format|
      if is_duplicate or @post.save
        if !is_duplicate
          @post.user.hooks.each do |hook|
            # TODO I'd like to make this a helper of some sort
            case hook.provider
            when 'hipchat'
              client = HipChat::Client.new(hook.params['token'])
              notify_users = true
              message = render_to_string :partial => 'posts/hipchat_message.html.erb'
              client[hook.params['room']].send('Reading.am', "#{message}", notify_users)
            when 'campfire'
              campfire = Tinder::Campfire.new hook.params['subdomain'], :token => hook.params['token']
              room = campfire.find_or_create_room_by_name(hook.params['room'])
              if !room.nil?
                room.speak render_to_string :partial => 'posts/campfire_message.txt.erb'
              end
            when 'url'
              url = Addressable::URI.parse(hook.params['url'])
              if hook.params['method'] == 'get'
                query_values = url.query_values || {}
                # this chokes unless you wrap ints in quotes per: http://stackoverflow.com/questions/3765834/cant-convert-fixnum-to-string-during-rake-dbcreate
                url.query_values = query_values.update({
                  'post[id]'                  => "#{@post.id}",
                  'post[title]'               => @post.page.title,
                  'post[url]'                 => @post.page.url,
                  'post[wrapped_url]'         => @post.wrapped_url,
                  'post[user][username]'      => @post.user.username,
                  'post[user][display_name]'  => @post.user.display_name,
                  'post[referrer_post][id]'                 => !@post.referrer_post.nil? ? "#{@post.referrer_post.id}" : '',
                  'post[referrer_post][user][username]'     => !@post.referrer_post.nil? ? @post.referrer_post.user.username : '',
                  'post[referrer_post][user][display_name]' => !@post.referrer_post.nil? ? @post.referrer_post.user.display_name : ''
                })
                Curl::Easy.perform url.to_s
              else
                Curl::Easy.http_post(
                  url.to_s,
                  Curl::PostField.content('post[id]', @post.id),
                  Curl::PostField.content('post[title]', @post.page.title),
                  Curl::PostField.content('post[url]', @post.page.url),
                  Curl::PostField.content('post[wrapped_url]', @post.wrapped_url),
                  Curl::PostField.content('post[user][username]', @post.user.username),
                  Curl::PostField.content('post[user][display_name]', @post.user.display_name),
                  Curl::PostField.content('post[referrer_post][id]', !@post.referrer_post.nil? ? @post.referrer_post.id : ''),
                  Curl::PostField.content('post[referrer_post][user][username]', !@post.referrer_post.nil? ? @post.referrer_post.user.username : ''),
                  Curl::PostField.content('post[referrer_post][user][display_name]', !@post.referrer_post.nil? ? @post.referrer_post.user.display_name : '')
                )
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
    @referrer_id = params[:id] ? Base58.decode(params[:id]) : 0;
  end
end
