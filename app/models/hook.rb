class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:pusher, :hipchat, :campfire, :url, :opengraph]
  validates_presence_of :provider, :params

  def params
    ActiveSupport::JSON.decode(read_attribute(:params))
  end

  def run post, event
    self.send(self.provider, post, event)
  end

  def pusher post, event
    json = post.to_json.html_safe
    Pusher['everybody'].trigger_async("#{event}_obj", json)
    Pusher[post.user.username].trigger_async("#{event}_obj", json)
  end

  def hipchat post, event
    client = HipChat::Client.new(self.params['token'])
    message = render_to_string :partial => "posts/hipchat_#{event}.html.erb", :locals => {:post => post}
    client[self.params['room']].send('Reading.am', "#{message}", (event == :new)) # only notify if this is not a post update
  end

  def campfire post, event
    campfire = Tinder::Campfire.new self.params['subdomain'], :token => self.params['token']
    room = campfire.find_or_create_room_by_name(self.params['room'])
    room.speak render_to_string :partial => "posts/campfire_#{event}.txt.erb" if !room.nil?
  end

  def opengraph post, event
    if event == :new
      auth = Authorization.find_by_user_id_and_provider(post.user_id, 'facebook')
      if auth and auth.token
        url = "https://graph.facebook.com/me/reading-am:#{post.domain.imperative}"
        http = EventMachine::HttpRequest.new(url).post :body => {
          :access_token => auth.token,
          #gsub for testing since Facebook doesn't like my localhost
          :website => post.wrapped_url.gsub('0.0.0.0:3000', 'reading.am')
        }
      end
    end
  end

  def url post, event
    url = self.params['url']
    url = "http://#{url}" if url[0, 4] != "http"
    http = EventMachine::HttpRequest.new(url)

    data = { :post => post.simple_obj(true) }
    if self.params['method'] == 'get'
      addr = Addressable::URI.new
      addr.query_values = data # this chokes unless you wrap ints in quotes per: http://stackoverflow.com/questions/3765834/cant-convert-fixnum-to-string-during-rake-dbcreate
      http.get :query => addr.query
    else
      http.post :body => data
    end
  end

end
