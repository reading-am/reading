class ExtrasController < ApplicationController
  def safari_update
    render "safari_update.plist", :content_type => "application/plist", :layout => false
  end
end
