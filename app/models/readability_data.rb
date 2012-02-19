class ReadabilityData < ActiveRecord::Base
  belongs_to :page
  before_create :populate_from_remote

  def remote
    c = Curl::Easy.new
    c.follow_location = true
    c.url = "https://www.readability.com/api/content/v1/parser?token=#{READABILITY_TOKEN}&url=#{page.url}"
    c.perform
    c.body_str
  end

  def populate_from_remote
    obj = Yajl::Parser.parse remote rescue nil
    self.attributes = obj unless obj.blank? or obj['error']
  end
end
