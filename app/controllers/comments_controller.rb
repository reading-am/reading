# encoding: utf-8
class CommentsController < ApplicationController

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    if @comment.user.username != params[:username]
      redirect_to "/#{@comment.user.username}/comments/#{@comment.id}"
    else
      respond_to do |format|
        format.html { render layout: 'backbone' }
        format.xml  { render xml:    @comment }
      end
    end
  end


  def shortener
    @comment = Comment.find(Base58.decode(params[:id]))
    redirect_to "/#{@comment.user.username}/comments/#{@comment.id}"
  end

end
