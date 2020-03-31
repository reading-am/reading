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

    def show
      render locals: { comment: Comment.find(params[:id]) }
    end
    require_scope_for :show, :public

    def create
      comment = Comment.new

      # Note - an associated post is not required
      comment.post  = Post.find(params[:model][:post_id]) unless params[:model][:post_id].blank?
      comment.user  = current_user
      comment.page  = Page.find(params[:model][:page_id])
      comment.body  = params[:model][:body]

      if comment.save
        render :show, status: :created, locals: { comment: comment }
      else
        head :bad_request
      end
    end
    require_scope_for :create, :write

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

    def destroy
      comment = Comment.find(params[:id])

      comment.destroy if current_user == comment.user
      head :no_content
    end
    require_scope_for :destroy, :write

    def stats
      render 'shared/stats', locals: { model: Comment }
    end
    require_scope_for :stats, :admin
  end
end
