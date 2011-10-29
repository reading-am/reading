class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:hipchat, :campfire, :url, :opengraph]
  validates_presence_of :provider, :params

  def params
    ActiveSupport::JSON.decode(read_attribute(:params))
  end

  def run post, is_update
    self.send(self.provider, post, is_update)
  end

  def hipchat post
    client = HipChat::Client.new(self.params['token'])
    notify_users = !is_update # only notify if this is not a post update
    message = render_to_string :partial => "posts/hipchat_#{is_update ? 'update' : 'new'}.html.erb", :locals => {:post => post}
    client[self.params['room']].send('Reading.am', "#{message}", notify_users)
  end

  def campfire post
    campfire = Tinder::Campfire.new self.params['subdomain'], :token => self.params['token']
    room = campfire.find_or_create_room_by_name(self.params['room'])
    if !room.nil?
      room.speak render_to_string :partial => "posts/campfire_#{is_update ? 'update' : 'new'}.txt.erb"
    end
  end

  def opengraph post
    if !is_update
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

  def url post
    data = { :post => {
      :id             => "#{post.id}",
      :yn             => post.yn,
      :title          => post.page.title,
      :url            => post.page.url,
      :wrapped_url    => post.wrapped_url,
      :user => {
        :id           => "#{post.user.id}",
        :username     => post.user.username,
        :display_name => post.user.display_name
      },
      :referrer_post => {
        :id           => !post.referrer_post.nil? ? "#{post.referrer_post.id}" : '',
        :user => {
          :id         => !post.referrer_post.nil? ? "#{post.referrer_post.user.id}" : '',
          :username   => !post.referrer_post.nil? ? post.referrer_post.user.username : '',
          :display_name => !post.referrer_post.nil? ? post.referrer_post.user.display_name : ''
        }
      }
    }}

    url = self.params['url']
    if url[0, 4] != "http" then url = "http://#{url}" end
    http = EventMachine::HttpRequest.new(url)

    if self.params['method'] == 'get'
      addr = Addressable::URI.new 
      addr.query_values = data # this chokes unless you wrap ints in quotes per: http://stackoverflow.com/questions/3765834/cant-convert-fixnum-to-string-during-rake-dbcreate
      http.get :query => addr.query
    else
      http.post :body => data
    end
  end

end
