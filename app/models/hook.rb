# encoding: UTF-8
include ActionView::Helpers::TextHelper

class Hook < ActiveRecord::Base
  belongs_to :user
  belongs_to :authorization
  validates_presence_of :events, :provider

  EVENTS = {
    :new  => {:perms => [:write], :text => 'read a page'},
    :yep  => {:perms => [:write], :text => 'say "yep"'},
    :nope => {:perms => [:write], :text => 'say "nope"'},
    :comment => {:perms => [:write], :text => 'comment'}
  }

  PLACE_TYPES = {
    'tumblr'  => 'blog',
    'kippt'   => 'list',
    'campfire'=> 'room',
    'hipchat' => 'room',
    'evernote'=> 'notebook'
  }

  SINGLE_FIRE = ['twitter','instapaper','readability','tumblr','pinboard','evernote','kippt']

  def params
    Yajl::Parser.parse(read_attribute(:params)) unless read_attribute(:params).nil?
  end

  def place
    unless params['place'].blank?
      {
        :type => PLACE_TYPES[provider],
        :name => params['place']['name'],
        :id => params['place']['id']
      }
    end
  end

  def events
    if read_attribute(:events).class == Array
      read_attribute(:events)
    else
      Yajl::Parser.parse(read_attribute(:events)).map {|event| event.to_sym}
    end
  end

  def responds_to event
    events.include?(event) and (!SINGLE_FIRE.include?(provider) or (event == :new or !events.include?(:new)))
  end

  def run post, event_fired
    # right now, no hooks should run on duplicate
    # I should really handle all event_fired checking here
    self.send(self.provider, post, event_fired) if responds_to event_fired
  end
  handle_asynchronously :run

  def pusher post, event_fired
    event_fired = :update if [:yep,:nope].include? event_fired
    Pusher['everybody'].trigger("#{event_fired}_obj", post.simple_obj)
    Pusher[post.user.username].trigger("#{event_fired}_obj", post.simple_obj)
  end

  def facebook post, event_fired
    case params['permission']
    when 'publish_stream' # wall
      authorization.api.put_object("me", "links", :link => post.wrapped_url, :message => "✌ #{post.page.domain.verb.capitalize} \"#{post.page.display_title}\"") rescue nil
    when 'publish_actions' # timeline
      action = post.domain.imperative
      action = "read" if action == "listen" # we didn't get approved for listen
      authorization.api.put_connections("me", "reading-am:#{action}", :website => post.wrapped_url.gsub('0.0.0.0:3000', 'reading.am'))
    end
  end

  def instapaper post, event_fired
    authorization.api.add_bookmark post.page.url rescue nil
  end

  def readability post, event_fired
    authorization.api.bookmark :url => post.page.url
  end

  def pinboard post, event_fired
    Typhoeus::Request.get 'https://api.pinboard.in/v1/posts/add',
      :username => self.params['user'],
      :password => self.params['password'],
      :params => {
        :url => post.page.url,
        :description => post.page.display_title,
        :tags => 'Reading.am'
      }
  end

  def tumblr post, event_fired
    authorization.api.link "#{self.place[:id]}.tumblr.com", post.wrapped_url, {:title => "✌ #{post.page.display_title}", :description => post.page.excerpt}
  end

  def twitter post, event_fired
    # grabbed a zero width space from here: http://en.wikipedia.org/wiki/Space_(punctuation)#Spaces_in_Unicode
    tweet = "✌ #{post.page.domain.verb.capitalize} \"#{post.page.display_title}\""
    tweet_len = tweet.unpack('c*').length
    full_len = tweet_len + post.short_url.unpack('c*').length + 1 # plus one is the space
    buffer = 10 # 10 for good measure and because twitter drove me batty about being over the character limit
    if full_len + buffer > 140
      # after trying to count characters the twitter way: https://dev.twitter.com/docs/counting-characters#Ruby_Specific_Information
      # I finally gave up and just used the actual byte length
      cutto = tweet_len - (full_len + "…".unpack('c*').length - 140) - buffer
      tweet = "#{tweet[0..cutto]}…\""
    end
    tweet << " #{post.short_url}"
    # we rescue with nil because twitter will error out on duplicate tweets
    authorization.api.update tweet rescue nil
  end

  def hipchat obj, event_fired
    case event_fired
    when :new, :yep, :nope
      post = obj
    when :comment
      post = obj.post
    end
    user = obj.user

    user_link = "<a href='http://#{DOMAIN}/#{user.username}'>#{user.display_name}</a>"
    post_link = "<a href='#{post.wrapped_url}'>#{post.page.display_title}</a>"
    post_link_truncated = "<a href='#{post.wrapped_url}'>#{truncate(post.page.display_title)}</a>"

    case event_fired
    when :new
      output = "✌ #{user_link} is #{!post.page.domain.nil? ? post.page.domain.verb : 'reading'} #{post_link}"
      output += " because of <a href='http://#{DOMAIN}/#{post.referrer_post.user.username}'>#{post.referrer_post.user.display_name}</a>" if post.referrer_post and post.user != post.referrer_post.user
    when :yep, :nope
      output = "#{post.yn ? '✓' : '×'} #{user_link} said \"#{post.yn ? 'yep' : 'nope'}\" to #{post_link}"
    when :comment
      output = "#{obj.body_html} | ✌ <em>#{user_link} said on #{post_link_truncated}</em>"
    end

    colors = {
      :new => "yellow",
      :yep => "green",
      :nope => "red",
      :comment => "purple"
    }

    client = HipChat::Client.new(params['token'])
    client[place[:id]].send('Reading.am', output, :color => colors[event_fired], :notify => (event_fired == :new)) # only notify if this is not a post update
  end

  # For legacy support. If you finally remove this, also remove
  # the room param from tssignals and the ||= assignment
  def campfire post, event_fired
    campfire = Tinder::Campfire.new self.params['subdomain'], :token => self.params['token']
    room = campfire.find_or_create_room_by_name(self.place[:id])
    self.tssignals post, event_fired, room
  end

  def evernote post, event_fired
  end

  def tssignals post, event_fired, room=nil
    post_link = "\"#{post.page.display_title}\" #{post.wrapped_url}"
    case event_fired
    when :new
      output = "✌ #{post.page.domain.verb.capitalize} #{post_link}"
      output += " because of #{post.referrer_post.user.display_name} (http://#{DOMAIN}/#{post.referrer_post.user.username})" if post.referrer_post and post.user != post.referrer_post.user
    when :yep, :nope
      output = "#{post.yn ? '✓' : '×' } #{post.yn ? 'Yep' : 'Nope'} to #{post_link}"
    end

    room ||= authorization.api.find_room_by_id(self.params['room']['id'].to_i)
    room.speak output if !room.nil?
  end

  def kippt post, event_fired
    clip = authorization.api.clips.build
    clip.url = post.page.url
    clip.list = place[:id]
    clip.save
  end

  def url post, event_fired
    url = self.params['address']
    url = "http://#{url}" if url[0, 4] != "http"
    Typhoeus::Request.send params['method'], url, :params => {:post => post.simple_obj(true)}
  end

end
