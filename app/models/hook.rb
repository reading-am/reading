# encoding: utf-8
include ActionView::Helpers::TextHelper

class Hook < ApplicationRecord
  include RenderApi

  serialize :events, JSON
  serialize :params, JSON

  belongs_to :user
  belongs_to :authorization
  validates_presence_of :events, :provider
  before_save :parse_pinboard_token

  EVENTS = {
    'new'     => {perms: [:write], text: 'read a page'},
    'yep'     => {perms: [:write], text: 'say "yep"'},
    'nope'    => {perms: [:write], text: 'say "nope"'},
    'comment' => {perms: [:write], text: 'comment'}
  }

  PLACE_TYPES = {
    'tumblr'  => 'blog',
    'evernote'=> 'notebook',
    'slack'   => 'room'
  }

  SINGLE_FIRE = [
    'twitter',
    'instapaper',
    'readability',
    'tumblr',
    'pinboard',
    'evernote',
    'pocket'
  ]

  def place
    unless params['place'].blank?
      {
        :type => PLACE_TYPES[provider],
        :name => params['place']['name'],
        :id => params['place']['id']
      }
    end
  end

  def responds_to event
    event = event.to_s
    events.include?(event) && (!SINGLE_FIRE.include?(provider) || (event == 'new' || !events.include?('new')))
  end

  def run(post, event_fired)
    return unless responds_to event_fired
    HookJob.perform_later(self, post, event_fired.to_s)
  end

  def facebook(post, event_fired)
    case params['permission']
    when 'publish_stream' # wall
      authorization.api.put_object("me", "links", :link => post.wrapped_url, :message => "✌ #{post.page.verb.capitalize} \"#{post.page.display_title}\"") rescue nil
    when 'publish_actions' # timeline
      action = post.page.imperative
      action = "read" if action == "listen" # we didn't get approved for listen
      authorization.api.put_connections("me", "reading-am:#{action}", :website => post.wrapped_url.gsub('.dev:3000', '.am'))
    end
  end

  def instapaper(post, event_fired)
    authorization.api.add_bookmark post.page.url rescue nil
  end

  def readability(post, event_fired)
    authorization.api.bookmark :url => post.page.url
  end

  def pinboard(post, event_fired)
    Typhoeus::Request.get 'https://api.pinboard.in/v1/posts/add',
      :params => {
        :auth_token => "#{self.params['user']}:#{self.params['token']}",
        :url => post.page.url,
        :description => post.page.display_title,
        :tags => 'Reading.am'
      }
  end

  def tumblr(post, event_fired)
    # this must use string rather than symbol keys in the options hash
    authorization.api.link "#{self.place[:id]}.tumblr.com", post.wrapped_url, {"title" => "✌ #{post.page.display_title}", "description" => post.page.description, "state" => params["state"] || "published"}
  end

  def twitter(post, event_fired)
    # grabbed a zero width space from here: http://en.wikipedia.org/wiki/Space_(punctuation)#Spaces_in_Unicode
    tweet = "✌ @#{post.page.verb.capitalize} \"#{post.page.display_title}\""
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

  def hipchat(obj, event_fired)
    case event_fired
    when 'new', 'yep', 'nope'
      post = obj
    when 'comment'
      post = obj.post
    end
    user = obj.user

    user_link = "<a href='#{ROOT_URL}/#{user.username}'>#{user.display_name}</a>"
    post_link = "<a href='#{post.wrapped_url}'>#{post.page.display_title}</a>"
    post_link_truncated = "<a href='#{post.wrapped_url}'>#{truncate(post.page.display_title)}</a>"

    case event_fired
    when 'new'
      output = "✌ #{user_link} is #{post.page.verb} #{post_link}"
      output += " because of <a href='#{ROOT_URL}/#{post.referrer_post.user.username}'>#{post.referrer_post.user.display_name}</a>" if post.referrer_post and post.user != post.referrer_post.user
    when 'yep', 'nope'
      output = "#{post.yn ? '✓' : '×'} #{user_link} said \"#{post.yn ? 'yep' : 'nope'}\" to #{post_link}"
    when 'comment'
      output = "#{obj.body_html} | ✌ <em>#{user_link} said on #{post_link_truncated}</em>"
    end

    colors = {
      'new'     => 'yellow',
      'yep'     => 'green',
      'nope'    => 'red',
      'comment' => 'purple'
    }

    client = HipChat::Client.new(params['token'])
    client[params['room']].send('Reading.am', output, color: colors[event_fired], notify: (event_fired == 'new')) # only notify if this is not a post update
  end

  def evernote(post, event_fired)
    note = Evernote::EDAM::Type::Note.new
    note.notebookGuid = place[:id]
    note.title = post.page.title
    note.content = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
  <div style="font-family:Helvetica,Arial,sans-serif">
    <h3>#{CGI.escapeHTML post.page.title}</h3>
    <a href="#{CGI.escapeHTML post.page.url}">#{CGI.escapeHTML post.page.url}</a>
  </div>
</en-note>
EOF
    authorization.api.createNote authorization.token, note
  end

  def pocket(post, event_fired)
    Typhoeus::Request.post 'https://getpocket.com/v3/add',
                           params: {
                             consumer_key: ENV['POCKET_KEY'],
                             access_token: authorization.token,
                             url: post.page.url,
                             tags: '✌ Reading'
                           }
  end

  def slack(obj, event_fired)
    case event_fired
    when 'new', 'yep', 'nope'
      post = obj
    when 'comment'
      post = obj.post
    end

    # https://api.slack.com/docs/attachments
    body = {
      title: post.page.display_title,
      title_link: post.wrapped_url,
      color: {
        'new'     => '#fff300',
        'yep'     => '#38ff7E',
        'nope'    => '#ff0000',
        'comment' => '#b01ecf'
      }[event_fired]
    }

    case event_fired
    when 'new'
      text = "✌ #{post.page.verb.capitalize}:"
      body[:fallback] = "#{text} #{post.page.display_title} | #{post.wrapped_url}"
    when 'yep', 'nope'
      text = post.yn ? '👍 Yep' : '👎 Nope'
      body[:fallback] = "#{text}: #{post.page.display_title} | #{post.wrapped_url}"
    when 'comment'
      text = obj.body
      body[:fallback] = "#{obj.body}\n#{post.wrapped_url}"
    end

    if event_fired == 'new' || !events.include?('new')
      body = body.merge({ text: post.page.display_description,
                          image_url: post.page.primary_image,
                          author_name: post.page.author['name'],
                          author_link: post.page.author['url'],
                          author_icon: post.page.author['avatar']['url'] })
    end

    authorization.api.chat_postMessage channel: params['place']['id'],
                                       text: text,
                                       attachments: [body],
                                       as_user: true
  end

  def url(post, event_fired)
    amap = { 'get' => :params, 'post' => :body }
    method = params['method']
    url = params['address']
    url = "http://#{url}" if url[0, 4] != 'http'
    Typhoeus.send method, url, amap[method] => { post: render_api(post) }
  end

  private

  def parse_pinboard_token
    if provider == 'pinboard' and !self.params['auth_token'].blank?
      bits = self.params['auth_token'].split(':')
      self.params = {user: bits[0], token: bits[1]}
    end
  end
end
