# encoding: utf-8
class Api::PostsController < Api::APIController

  private

  def post_params
    params.require(:model).permit(:yn)
  end

  public

  # NOTE - this is also being used for events as
  # the only events we have right now are posts.
  # Will spin out when we aggregate in comments.

  def index
    posts = Api::Posts.index(params)

    if signed_in?
      posts = posts.select { |post| current_user.can_play_with(post.user) }
    end

    respond_to do |format|
      format.json do
        render_json posts: posts.map { |post| post.simple_obj }
      end
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :index
  add_transaction_tracer :index

  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json { render_json post: @post.simple_obj }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :show
  add_transaction_tracer :show

  def create
    user, url, title, page, ref, yn = nil

    # post via email
    if params[:recipient]
      text = params['stripped-text'] # this comes from mailgun
      url = Twitter::Extractor::extract_urls(text)[0]

      # check to see if the body contains yep or nope
      if !text.match(/(^|\s)yep($|\s|:)/i).nil?
        yn = true
      elsif !text.match(/(^|\s)nope($|\s|:)/i).nil?
        yn = false
      end

      if bits = MailPipe::decode_mail_recipient(params[:recipient])
        user = bits[:user] if bits[:user] == bits[:subject] # make sure the user is posting to their own account
      end
    # standard post
    else
      url   = params[:model][:url]
      title = params[:model][:title] unless params[:model][:title].blank? || params[:model][:title] == 'null'
      desc  = params[:model][:description] unless params[:model][:description].blank? || params[:model][:description] == 'null'
      user  = current_user
      ref   = Post.find_by_id(params[:model][:referrer_post_id]) unless params[:model][:referrer_post_id].blank?
      yn    = params[:model][:yn]
    end

    page = params[:model] && params[:model][:page_id] ? Page.find(params[:model][:page_id]) : Page.find_or_create_by_url(url: url, title: title, description: desc)
    # A post is a duplicate if it's the exact same page and within 1hr of the last post
    @post = Post.recent_by_user_and_page(user, page).first || Post.new(user: user, page: page, referrer_post: ref, yn: yn)

    respond_to do |format|
      if (@post.new_record? and @post.save) or (!@post.new_record? and @post.touch)
        format.html { redirect_to(@post, notice: 'Post was successfully created.') }
        format.xml  { render xml: @post, status: :created, location: @post }
        format.json { render_json post: @post.simple_obj }
      else
        # TODO clean up this auth hack. Ugh.
        status = @post.user.blank? ? :forbidden : :bad_request
        format.json { render_json status }
      end
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :create
  add_transaction_tracer :create

  def update
    @post = Post.find(params[:id])

    pms = post_params
    if allowed = (current_user == @post.user)
      pms[:yn] = nil if !pms[:yn].nil? and pms[:yn] == 'null'
      @post.yn = pms[:yn]
    end

    respond_to do |format|
      if allowed and ((@post.changed? and @post.save) or (!@post.changed? and @post.touch))
        status = :ok
      else
        status = allowed ? :bad_request : :forbidden
      end
      format.json { render_json status }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :update
  add_transaction_tracer :update

  def destroy
    @post = Post.find(params[:id])

    @post.destroy if current_user == @post.user

    respond_to do |format|
      status = @post.destroyed? ? :ok : :forbidden
      format.json { render_json status }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :destroy
  add_transaction_tracer :destroy

  def count
    if current_user.roles? :admin
      respond_to do |format|
        format.json { render_json :total_posts => Post.count }
      end
    else
      show_404
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :count
  add_transaction_tracer :count

end
