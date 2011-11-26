# encoding: UTF-8
class Hook < ActiveRecord::Base
  belongs_to :user
  belongs_to :authorization
  validates_presence_of :event, :provider

  EVENTS = {
    :all  => {:perms => [:write], :text => 'read, "yep" or "nope"'},
    :new  => {:perms => [:write], :text => 'read a page'},
    :yep  => {:perms => [:write], :text => 'say "yep"'},
    :nope => {:perms => [:write], :text => 'say "nope"'}
  }
  PROVIDERS = [
    :hipchat,
    :campfire,
    :url,
    :opengraph
  ]

  def params
    ActiveSupport::JSON.decode(read_attribute(:params))
  end

  def event
    read_attribute(:event).to_sym
  end

  def run post, event_fired
    # right now, no hooks should run on duplicate
    # I should really handle all event_fired checking here
    self.send(self.provider, post, event_fired) if event_fired != :duplicate and event == :all or event == event_fired
  end

  def pusher post, event_fired
    event_fired = :update if [:yep,:nope].include? event_fired
    Pusher['everybody'].trigger_async("#{event_fired}_obj", post.simple_obj)
    Pusher[post.user.username].trigger_async("#{event_fired}_obj", post.simple_obj)
  end

  def facebook post, event_fired
    authorization.api.put_object("me", "feed", :message => "✌ #{post.page.domain.verb.capitalize} http://#{post.short_url} \"#{post.page.title}\"")
  end

  def twitter post, event_fired
    # grabbed a zero width space from here: http://en.wikipedia.org/wiki/Space_(punctuation)#Spaces_in_Unicode
    tweet = "✌ #{post.page.domain.imperative.capitalize}​#{post.short_url} \"#{post.page.title}\""
    if tweet.unpack('c*').length > 140
      # after trying to count characters the twitter way: https://dev.twitter.com/docs/counting-characters#Ruby_Specific_Information
      # I finally gave up and just used the actual byte length
      cutto = tweet.length - ("#{tweet}…\"".unpack('c*').length - 140) - 5 # -5 for good measure and because twitter drove me batty
      tweet = "#{tweet[0..cutto]}…\""
    end
    authorization.api.update tweet
  end

  def hipchat post, event_fired
    user_link = "<a href='http://#{DOMAIN}/#{post.user.username}'>#{post.user.display_name}</a>"
    post_link = "<a href='#{post.wrapped_url}'>#{post.page.title.blank? ? post.page.url : post.page.title}</a>"
    case event_fired
    when :new
      output = "✌ #{user_link} is #{!post.page.domain.nil? ? post.page.domain.verb : 'reading'} #{post_link}"
      output += " because of <a href='http://#{DOMAIN}/#{post.referrer_post.user.username}'>#{post.referrer_post.user.display_name}</a>" if post.referrer_post and post.user != post.referrer_post.user
    when :yep, :nope
      output = "#{post.yn ? '✓' : '×'} #{user_link} said \"#{post.yn ? 'yep' : 'nope'}\" to #{post_link}"
    end

    client = HipChat::Client.new(self.params['token'])
    client[self.params['room']].send('Reading.am', output, (event_fired == :new)) # only notify if this is not a post update
  end

  def campfire post, event_fired
    post_link = "#{'"' + post.page.title + '" ' if !post.page.title.blank?}#{post.wrapped_url}"
    case event_fired
    when :new
      output = "✌ #{post.page.domain.verb.capitalize} #{post_link}"
      output += " because of #{post.referrer_post.user.display_name} (http://#{DOMAIN}/#{post.referrer_post.user.username})" if post.referrer_post and post.user != post.referrer_post.user
    when :yep, :nope
      output = "#{post.yn ? '✓' : '×' } #{post.yn ? 'Yep' : 'Nope'} to #{post_link}"
    end

    campfire = Tinder::Campfire.new self.params['subdomain'], :token => self.params['token']
    room = campfire.find_or_create_room_by_name(self.params['room'])
    room.speak output if !room.nil?
  end

  def opengraph post, event_fired
    if event_fired == :new
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

  def url post, event_fired
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
