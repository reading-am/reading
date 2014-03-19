# encoding: utf-8
class ExportController < ApplicationController

  def index
    t = Time.new.to_i
    query = {
      timestamp: t,
      token: Digest::SHA1.hexdigest("#{t}#{current_user.token}#{Reading::Application.config.secret_key_base}")
    }
    redirect_to "http://export.#{ROOT_DOMAIN}/#{current_user.username}/posts.#{request.params[:format]}?#{query.to_query}"
  end

end
