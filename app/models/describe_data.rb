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
    temp = Tempfile.new("page.html")
    temp.write html
    begin
      resp = Typhoeus.post "http://#{ENV['DESCRIBE_HOST']}:#{ENV['DESCRIBE_PORT']}",
                           body: { format: 'json', url: page.url, file: File.open(temp.path, 'r') }
      obj = ActiveSupport::JSON.decode resp.body
      self.response = obj["response"] unless obj.blank? or obj["error"]
    rescue Exception => e
      puts e
      nil
    ensure
      temp.close!
    end

    ## This works for curb / curl but multipart_form_post = true
    ## causes a segfault
    # file = Curl::PostField.content('file', html)
    # file.remote_file = 'page.html'
    # file.content_type = 'application/octet-stream'
    # c = Curl::Easy.new("http://#{ENV['DESCRIBE_HOST']}:#{ENV['DESCRIBE_PORT']}")
    # c.multipart_form_post = true
    # c.http_post(Curl::PostField.content('format', 'json'),
    #             Curl::PostField.content('url', page.url),
    #             file)
    # perform c
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
