class DescribeData < ActiveRecord::Base
  serialize :response, JSON
  belongs_to :page

  validates_presence_of :page, :response
  before_validation { fetch if new_record? and response.blank? }

  def fetch
    c = Curl::Easy.new "http://#{ENV['DESCRIBE_HOST']}:#{ENV['DESCRIBE_PORT']}?" +
        {url: page.url, format: "json"}.to_query
    perform c
  end

  def parse html
    file = Curl::PostField.content('file', html)
    file.remote_file = 'page.html'
    file.content_type = 'application/octet-stream'

    c = Curl::Easy.http_post("http://#{ENV['DESCRIBE_HOST']}:#{ENV['DESCRIBE_PORT']}",
                             Curl::PostField.content('format', 'json'),
                             Curl::PostField.content('url', page.url),
                             file)
    c.multipart_form_post = true
    perform c
  end

  private

  def perform curl
    curl.follow_location = true
    begin
      curl.perform
      obj = ActiveSupport::JSON.decode curl.body_str
      self.response = obj["response"] unless obj.blank? or obj["error"]
    rescue Exception => e
      puts e
      nil
    end
  end
end
