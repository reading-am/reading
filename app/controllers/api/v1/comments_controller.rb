# encoding: utf-8
module Api::V1
  class CommentsController < ApiController

    private

    def comment_params
      params.require(:model).permit(:body)
    end

    public

    def index
      comments = Comments.index(params)

      if signed_in?
        comments = comments.select { |comment| current_user.can_play_with(comment.user) }
      end

      render locals: { comments: comments }
    end
    require_scope_for :index, :public
    add_transaction_tracer :index

    def show
      render locals: { comment: Comment.find(params[:id]) }
    end
    require_scope_for :show, :public
    add_transaction_tracer :show

    def create
      comment = Comment.new

      if params[:recipient]
        comment.body = params['stripped-text'] # this comes from mailgun
        if bits = MailPipe::decode_mail_recipient(params[:recipient])
          comment.user   = bits[:user]
          comment.parent = bits[:subject]
          comment.page   = comment.parent.page
        end
      else
        # Note - an associated post is not required
        comment.post  = Post.find(params[:model][:post_id]) unless params[:model][:post_id].blank?
        comment.user  = current_user
        comment.page  = Page.find(params[:model][:page_id])
        comment.body  = params[:model][:body]
      end

      if comment.save
        render :show, status: :created, locals: { comment: comment }
      else
        head :bad_request
      end
    end
    require_scope_for :create, :write
    add_transaction_tracer :create

    def update
      comment = Comment.find(params[:id])

      if current_user != comment.user
        head :forbidden
      elsif comment.update_attributes(comment_params)
        render :show, locals: { comment: comment }
      else
        head :unprocessable_entity
      end
    end
    require_scope_for :update, :write
    add_transaction_tracer :update

    def destroy
      comment = Comment.find(params[:id])

      comment.destroy if current_user == comment.user
      head :no_content
    end
    require_scope_for :destroy, :write
    add_transaction_tracer :destroy

    def count
      render_json total_comments: Comment.count
    end
    require_scope_for :count, :admin
    add_transaction_tracer :count
  end
end
