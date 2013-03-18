class RssFeed < ActiveRecord::Base
  attr_accessible :page_id, :url

  belongs_to :page, :counter_cache => true
end
