# encoding: utf-8
class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    if @comment.user.username != params[:username]
      redirect_to "/#{@comment.user.username}/comments/#{@comment.id}"
    else
      respond_to do |format|
        format.html { render :layout => 'bb' }
        format.xml  { render :xml => @comment }
      end
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  def shortener
    @comment = Comment.find(Base58.decode(params[:id]))
    redirect_to "/#{@comment.user.username}/comments/#{@comment.id}"
  end

end
