class SwapPinboardUserPassForTokens < ActiveRecord::Migration
  def up
    Hook.where(:provider => 'pinboard').each do |hook|
      response = Typhoeus::Request.get 'https://api.pinboard.in/v1/user/api_token',
        :userpwd => "#{hook.params['user']}:#{hook.params['password']}",
        :params => {:format => 'json'}
      if response.code == 200
        body = Yajl::Parser.parse response.body
        if !body["result"].blank?
          hook.params = {:user => hook.params['user'], :token => body["result"]}.to_json
          hook.save
        end
      end
    end
  end

  def down
  end
end
