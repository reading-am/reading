# encoding: utf-8
class Api::CommentsController < Api::APIController

  # GET /comments
  # GET /comments.json
  def index
    if params[:page_id]
      where = {
        :cond => "page_id = :page_id",
        :params => {
          :page_id => params[:page_id]
        }
      }
      if !params[:after_created_at].blank?
        where[:cond] += " AND created_at > :after_created_at"
        where[:params][:after_created_at] = params[:after_created_at]
      end
      if !params[:after_id].blank?
        where[:cond] += " AND id > :after_id"
        where[:params][:after_id] = params[:after_id]
      end
      @comments = Comment.where(where[:cond], where[:params])
    else
      @comments =  Comment.order("created_at DESC")
                          .paginate(:page => params[:page])
    end

    respond_to do |format|
      format.json { render_json :comments => @comments.collect { |comment| comment.simple_obj } }
    end
  end
  add_transaction_tracer :index

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.fetch(params[:id])

    respond_to do |format|
      format.json { render_json :comment => @comment }
    end
  end
  add_transaction_tracer :show

  # POST /comments
  # POST /comments.json
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
      @comment.post  = Post.fetch(params[:model][:post_id]) unless params[:model][:post_id].blank?
      @comment.user  = params[:token] ? User.fetch_by_token(params[:token]) : current_user
      @comment.page  = Page.fetch(params[:model][:page_id])
      @comment.body  = params[:model][:body]
    end

    respond_to do |format|
      if @comment.save
        format.json { render_json({:comment => @comment.simple_obj}, :created) }
      else
        # TODO clean up this auth hack. Ugh.
        status = @comment.user.blank? ? :forbidden : :bad_request
        format.json { render_json status }
      end
    end
  end
  add_transaction_tracer :create

  def update
    @user  = params[:token] ? User.fetch_by_token(params[:token]) : current_user
    @comment = Comment.fetch(params[:id])

    respond_to do |format|
      if @user != @comment.user
        status = :forbidden
      elsif @comment.update_attributes(params[:model])
        status = :ok
      else
        status = :unprocessable_entity
      end
      format.json { render_json status }
    end
  end
  add_transaction_tracer :update

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @user  = params[:token] ? User.fetch_by_token(params[:token]) : current_user
    @comment = Comment.fetch(params[:id])

    @comment.destroy if @user == @comment.user

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
