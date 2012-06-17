# encoding: utf-8
class Api::CommentsController < ApplicationController
  # GET /comments
  # GET /comments.json
  def index
    # for JSONP requests
    if !params[:_method].blank?
      case params[:_method]
      when 'POST'
        return create()
      end
    end

    if params[:page_id]
      #@page = Page.find(params[:page_id])
      #@comments = @page.comments()
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
      @comments = Comment.from_users_followed_by(User.find(1)).where(where[:cond], where[:params])
    else
      @comments = Comment.order("created_at DESC")
                  .paginate(:page => params[:page])
    end

    respond_to do |format|
      format.json { render_json :comments => @comments.collect { |comment| comment.simple_obj } }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    # for JSONP requests
    if !params[:_method].blank?
      case params[:_method]
      when 'PUT'
        return update()
      when 'DELETE'
        return destroy()
      end
    end

    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.json { render_json :comment => @comment }
    end
  end

  # POST /comments
  # POST /comments.json
  def create
    # OPT - we don't need to make all of these selections
    @comment       = Comment.new
    @comment.post  = Post.find(params[:model][:post_id])
    @comment.user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @comment.page  = Page.find(params[:model][:page_id])
    @comment.body  = params[:model][:body]

    respond_to do |format|
      if @comment.save
        # We treat Pusher just like any other hook except that we don't store it
        # with the user so we go ahead and construct one here
        event = :comment
        Hook.new({:provider => 'pusher', :events => [:new,:yep,:nope]}).run(@comment, event)
        @comment.user.hooks.each do |hook| hook.run(@comment, event) end

        User.mentioned_in(@comment)
          .where('id != ? AND email IS NOT NULL AND email_when_mentioned = ?', @comment.user.id, true).each do |user|
            UserMailer.mentioned(@comment, user).deliver
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
