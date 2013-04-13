# encoding: utf-8
class ExtrasController < ApplicationController

  def bookmarklet_loader
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    render "#{Rails.root}/app/assets/javascripts/bookmarklet/_loader.js.erb"
  end

  def safari_update
    render "safari_update.plist", :content_type => "application/plist", :layout => false
  end

end
