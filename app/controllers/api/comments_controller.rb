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

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.json { render_json :comment => @comment }
    end
  end

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
      @comment.post  = Post.find(params[:model][:post_id])
      @comment.user  = params[:token] ? User.find_by_token(params[:token]) : current_user
      @comment.page  = Page.find(params[:model][:page_id])
      @comment.body  = params[:model][:body]
    end

    respond_to do |format|
      if @comment.save
        # We treat Pusher just like any other hook except that we don't store it
        # with the user so we go ahead and construct one here
        event = :comment
        Hook.new({:provider => 'pusher', :events => [:new,:yep,:nope]}).run(@comment, event)
        @comment.user.hooks.each do |hook| hook.run(@comment, event) end

        User.mentioned_in(@comment).where('id != ?', @comment.user.id).each do |user|
          if !user.access? :comments
            user.access << :comments
            user.save
            UserMailer.delay.comments_welcome(user, @comment) if !user.email.blank?
          end

          if !user.email.blank? and user.email_when_mentioned
            @comment.is_a_show ? UserMailer.delay.shown_a_page(@comment, user)
                               : UserMailer.delay.mentioned(@comment, user)
          end
        end

        format.json { render_json({:comment => @comment.simple_obj}, :created) }
      else
        # TODO clean up this auth hack. Ugh.
        status = @comment.user.blank? ? :forbidden : :bad_request
        format.json { render_json status }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @comment = Comment.find(params[:id])

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

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @comment = Comment.find(params[:id])

    @comment.destroy if @user == @comment.user

    respond_to do |format|
      status = @comment.destroyed? ? :ok : :forbidden
      format.json { render_json status }
    end
  end
end
