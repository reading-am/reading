class DescribeData < ActiveRecord::Base
  serialize :response, JSON
  belongs_to :page
  before_create :populate_from_remote

  def populate_from_remote
    c = Curl::Easy.new
    c.follow_location = true
    c.url = "http://localhost:5000?" + {url: page.url, format: "json"}.to_query
    c.perform
    obj = ActiveSupport::JSON.decode c.body_str rescue nil
    self.response = obj unless obj.blank? or obj['error']
  end
end
