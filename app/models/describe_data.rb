class DescribeData < ActiveRecord::Base
  serialize :response, JSON
  belongs_to :page

  validates_presence_of :page

  before_create { fetch if response.blank? }

  def fetch
    c = Curl::Easy.new
    c.follow_location = true
    c.url = "http://#{ENV['DESCRIBE_HOST']}:#{ENV['DESCRIBE_PORT']}?" + {url: page.url, format: "json"}.to_query
    c.perform
    obj = ActiveSupport::JSON.decode c.body_str rescue nil
    self.response = obj["response"] unless obj.blank? or obj["error"]
  end
end
