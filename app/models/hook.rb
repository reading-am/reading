class Hook < ActiveRecord::Base
  belongs_to :user

  def execute
    if this.provider == 'hipchat'
      # api_token = '4acf4be53765ca92e1aca994811761'
      client = HipChat::Client.new(self.token)
      notify_users = true
      message = render_to_string :partial => 'posts/hipchat_message.html.erb'
      client[self.action].send('Reading.am', "#{message}", notify_users)
    end
  end
end
