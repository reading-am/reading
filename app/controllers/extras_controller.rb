# encoding: utf-8
class ExtrasController < ApplicationController

  def bookmarklet_loader
    set_no_cache_headers
    render "#{Rails.root}/app/assets/javascripts/bookmarklet/_loader.js.erb"
  end

  def safari_update
    render "safari_update.plist", :content_type => "application/plist", :layout => false
  end

end
