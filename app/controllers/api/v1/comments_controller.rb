# encoding: utf-8
module Api::V1
  class CommentsController < ApiController

    private

    def comment_params
      params.require(:model).permit(:body)
    end

    public

    def index
      @comments = Comments.index(params)

      if signed_in?
        @comments = @comments.select { |comment| current_user.can_play_with(comment.user) }
      end

      render
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :index
    add_transaction_tracer :index

    def show
      @comment = Comment.find(params[:id])
      render
    end
    add_transaction_tracer :show

    def create
      @comment = Comment.new

      if params[:recipient]
        @comment.body = params['stripped-text'] # this comes from mailgun
        if bits = MailPipe::decode_mail_recipient(params[:recipient])
          @comment.user   = bits[:user]
          @comment.parent = bits[:subject]
          @comment.page   = @comment.parent.page
        end
      else
        # Note - an associated post is not required
        @comment.post  = Post.find(params[:model][:post_id]) unless params[:model][:post_id].blank?
        @comment.user  = current_user
        @comment.page  = Page.find(params[:model][:page_id])
        @comment.body  = params[:model][:body]
      end

      respond_to do |format|
        if @comment.save
          render :show, status: :created
        else
          # TODO clean up this auth hack. Ugh.
          status = @comment.user.blank? ? :forbidden : :bad_request
          format.json { render_json status }
        end
      end
    end
    add_transaction_tracer :create

    def update
      @comment = Comment.find(params[:id])

      respond_to do |format|
        if current_user != @comment.user
          status = :forbidden
        elsif @comment.update_attributes(comment_params)
          status = :ok
        else
          status = :unprocessable_entity
        end
        format.json { render_json status }
      end
    end
    add_transaction_tracer :update

    def destroy
      @comment = Comment.find(params[:id])

      @comment.destroy if current_user == @comment.user

      respond_to do |format|
        status = @comment.destroyed? ? :ok : :forbidden
        format.json { render_json status }
      end
    end
    add_transaction_tracer :destroy

    def count
      if current_user.roles? :admin
        respond_to do |format|
          format.json { render_json :total_comments => Comment.count }
        end
      else
        show_404
      end
    end
    add_transaction_tracer :count

  end
end
