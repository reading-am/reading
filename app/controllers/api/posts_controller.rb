# encoding: utf-8
class Api::PostsController < Api::APIController
  # GET /posts
  # GET /posts.xml
  def index
    @posts =  Post.order("created_at DESC")
                  .includes([:user, :page, :domain, {:referrer_post => :user}])
                  .paginate(:page => params[:page])

    respond_to do |format|
      format.json { render_json :posts => @posts.collect { |post| post.simple_obj } }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json { render_json :post => @post.simple_obj }
    end
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
    @post.page  = Page.find_or_create_by_url(:url => url, :title => title)
    @post.yn    = params[:yn]

    if !@post.user.blank?
      # A post is a duplicate if it's the exact same page and within 1hr of the last post
      duplicate = Post.where("user_id = ? and page_id = ? and created_at > ?", @post.user, @post.page, 1.day.ago).first
      # TODO - clean up these conditionals for duplicates and the same in the respond_to
      if duplicate.blank?
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
        format.json { render_json({
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
          })
        }
      else
        # TODO clean up this auth hack. Ugh.
        status = @post.user.blank? ? :forbidden : :bad_request
        format.json { render_json status }
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
        status = :ok
      else
        status = allowed ? :bad_request : :forbidden
      end
      format.json { render_json status }
    end
  end

end
