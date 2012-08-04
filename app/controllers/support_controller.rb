# encoding: utf-8
class SupportController < ApplicationController

  def twozerofour
    head :no_content
  end

  def delete_cookies
    cookies.each do |k, v| cookies.delete k end
    redirect_to '/'
  end

end
