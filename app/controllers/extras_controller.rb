# encoding: utf-8
class ExtrasController < ActionController::Metal
  include AbstractController::Rendering
  include ActionView::Rendering
  include ActionController::Helpers
  include ActionController::Rendering
  include ActionController::Renderers::All
  include ActionController::ConditionalGet

  append_view_path File.join('/')
  append_view_path File.join(Rails.root, "app", "views")

  helper :application

  def bookmarklet_loader
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, pre-check=0, post-check=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    render "#{Rails.root}/app/assets/javascripts/bookmarklet/_loader.js.erb"
  end

  def safari_update
    render "#{Rails.root}/app/views/extras/safari_update.plist", :content_type => "application/plist", :layout => nil
  end

end
