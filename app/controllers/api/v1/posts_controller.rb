# encoding: utf-8
module Api::V1
  class PostsController < ApiController
    # NOTE - this is also being used for events as
    # the only events we have right now are posts.
    # Will spin out when we aggregate in comments.

    def index
      posts = Posts.index(params)

      if signed_in?
        posts = posts.select { |post| current_user.can_play_with(post.user) }
      end

      render locals: { posts: posts }
    end
    require_scope_for :index, :public
    add_transaction_tracer :index

    def show
      render locals: { post: Post.find(params[:id]) }
    end
    require_scope_for :show, :public
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
      post = Post.recent_by_user_and_page(user, page).first || Post.new(user: user, page: page, referrer_post: ref, yn: yn)

      if (post.new_record? and post.save) or (!post.new_record? and post.touch)
        render :show, locals: { post: post }
      else
        render_json post.user.blank? ? :forbidden : :bad_request
      end
    end
    require_scope_for :create, :write
    add_transaction_tracer :create

    def update
      post = Post.find(params[:id])

      pms = post_params
      if allowed = (current_user == post.user)
        pms[:yn] = nil if !pms[:yn].nil? and pms[:yn] == 'null'
        post.yn = pms[:yn]
      end

      if allowed and ((post.changed? and post.save) or (!post.changed? and post.touch))
        render :show, locals: { post: post }
      else
        render_json allowed ? :bad_request : :forbidden
      end
    end
    require_scope_for :update, :write
    add_transaction_tracer :update

    def destroy
      post = Post.find(params[:id])

      post.destroy if current_user == post.user

      respond_to do |format|
        status = post.destroyed? ? :ok : :forbidden
        format.json { render_json status }
      end
    end
    require_scope_for :destroy, :write
    add_transaction_tracer :destroy

    def stats
      render 'shared/stats', locals: { model: Post }
    end
    require_scope_for :stats, :admin
    add_transaction_tracer :stats

    private

    def post_params
      params.require(:model).permit(:yn)
    end
  end
end
