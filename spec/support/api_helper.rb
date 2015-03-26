module Rack
  class MockResponse
    attr_accessor :request
  end
end

# via: https://gist.github.com/alex-zige/5795358
module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def response
    last_response.request = last_request
    last_response
  end

  def set_auth_header(t=nil)
    header 'Authorization', "Bearer #{(t || token).token}"
  end

  def url_base
    '/api'
  end
end

RSpec.configure { |c| c.include ApiHelper, type: :api }
