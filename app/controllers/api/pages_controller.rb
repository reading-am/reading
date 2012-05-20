# encoding: utf-8
class Api::PagesController < ApplicationController

  def comments
    @page = Page.find(params[:id])
    respond_to do |format|
      format.json { render :json => {
        :meta => {
          :status => 200,
          :msg => 'OK'
        },
        :response => {
          :comments => @page.comments.collect { |comment|
            comment.simple_obj
          }
        }
      }, :callback => params[:callback] }
    end
  end

end

