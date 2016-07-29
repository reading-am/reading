class DescribeData < ApplicationRecord
  serialize :response, JSON
  belongs_to :page, counter_cache: :has_describe_data

  validates_presence_of :page, :response
  before_validation { fetch if new_record? and response.blank? }

  ENDPOINT = (ENV['DESCRIBE_PROTOCOL'].blank? ? "https" : ENV['DESCRIBE_PROTOCOL']) +
             "://#{ENV['DESCRIBE_HOST']}" +
             (ENV['DESCRIBE_PORT'].blank? ? "" : ":#{ENV['DESCRIBE_PORT']}")

  def fetch
    request = Typhoeus::Request.new(ENDPOINT, params: {
      url: page.url, format: "json"
    })
    run request
  end

  def parse html
    temp = Tempfile.new("page.html")
    temp.write html
    request = Typhoeus::Request.new(ENDPOINT, method: :post, body: {
      format: 'json',
      url: page.url,
      file: File.open(temp.path, 'r')
    })
    run request
    temp.close!
  end

  private

  def run request
    begin
      response = request.run
      obj = ActiveSupport::JSON.decode response.body
      self.response = obj["response"] unless obj.blank? or obj["error"]
    rescue Exception => e
      puts e
      nil
    end
  end
end
