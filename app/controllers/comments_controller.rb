class CommentsController < ApplicationController
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

    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
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
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment       = Comment.new
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

        format.html { redirect_to(@comment, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        format.json { render :json => {
          :meta => {
            :status => 201,
            :msg => 'Created'
          },
          :response => {
            :comment => @comment.simple_obj
          }
        }, :callback => params[:callback] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        if @comment.user.blank? # TODO clean up this auth hack. Ugh.
          format.json { render :json => {:meta => {:status => 403, :msg => "Forbidden"}, :response => {}}, :callback => params[:callback] }
        else
          format.json { render :json => {:meta => {:status => 400, :msg => "Bad Request #{@comment.errors.to_yaml}"}}, :callback => params[:callback] }
        end
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
        format.json { render :json => {:meta => {:status => 403, :msg => "Forbidden"}, :response => {}}, :callback => params[:callback] }
      elsif @comment.update_attributes(params[:model])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :json => {
          :meta => {
            :status => 200,
            :msg => 'OK'
          },
          :response => {}
        },:callback => params[:callback] }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @comment = Comment.find(params[:id])

    @comment.destroy if @user == @comment.user

    respond_to do |format|
      if !@comment.destroyed?
        format.json { render :json => {:meta => {:status => 403, :msg => "Forbidden"}, :response => {}}, :callback => params[:callback] }
      else
        format.html { redirect_to comments_url }
        format.json { render :json => {
          :meta => {
            :status => 200,
            :msg => 'OK'
          },
          :response => {}
        },:callback => params[:callback] }
      end
    end
  end
end
