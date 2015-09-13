# encoding: utf-8
class CommentsController < ApplicationController

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
    id = Base58.decode(params[:id]) rescue nil
    @comment = Comment.find(id)
    redirect_to "/#{@comment.user.username}/comments/#{@comment.id}"
  end
end
