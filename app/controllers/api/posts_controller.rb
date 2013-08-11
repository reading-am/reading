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
    respond_to do |format|
      format.json do
        render_json posts: Api::Posts.index(params).map { |post| post.simple_obj }
      end
    end
  end
  add_transaction_tracer :index

  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json { render_json post: @post.simple_obj }
    end
  end
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
      title = params[:model][:title] unless params[:model][:title] == 'null'
      head_tags = params[:model][:head_tags] unless params[:model][:head_tags] == 'null'
      user  = params[:token] ? User.find_by_token(params[:token]) : current_user
      ref   = Post.find_by_id(params[:model][:referrer_id]) unless params[:model][:referrer_id].blank?
      yn    = params[:model][:yn]
    end

    page = Page.find_or_create_by_url(url: url, title: title, head_tags: head_tags)
    # A post is a duplicate if it's the exact same page and within 1hr of the last post
    @post = Post.recent_by_user_and_page(user, page).first || Post.new(user: user, page: page, referrer_post: ref, yn: yn)

    respond_to do |format|
      if (@post.new_record? and @post.save) or @post.touch
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
  add_transaction_tracer :create

  def update
    @post = Post.find(params[:id])
    user = params[:token] ? User.find_by_token(params[:token]) : current_user

    pms = post_params
    if allowed = (user == @post.user)
      pms[:yn] = nil if !pms[:yn].nil? and pms[:yn] == 'null'
      @post.yn = pms[:yn]
    end

    respond_to do |format|
      if allowed and ((@post.changed? and @post.save) or @post.touch)
        status = :ok
      else
        status = allowed ? :bad_request : :forbidden
      end
      format.json { render_json status }
    end
  end
  add_transaction_tracer :update

  def destroy
    @user = params[:token] ? User.find_by_token(params[:token]) : current_user
    @post = Post.find(params[:id])

    @post.destroy if @user == @post.user

    respond_to do |format|
      status = @post.destroyed? ? :ok : :forbidden
      format.json { render_json status }
    end
  end
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
  add_transaction_tracer :count

end
