# from: http://net.tutsplus.com/tutorials/ruby/how-to-use-omniauth-to-authenticate-your-users/
class Authorization < ApplicationRecord

  serialize :info, JSON
  serialize :permissions, JSON

  belongs_to :user
  has_many :hooks, dependent: :destroy # also handled by foreign key

  validates :provider, :uid, presence: true
  before_create :set_initial_perms

  PROVIDERS = [
    'twitter',
    'facebook',
    'instapaper',
    'readability',
    'tumblr',
    'evernote',
    'pocket',
    'flattr',
    'slack'
  ]

private

  def set_initial_perms
    self.sync_perms if self.permissions.nil?
  end

public

  def self.transform_auth_hash auth_hash
    case auth_hash.provider
    when 'evernote'
      expires_at = Time.at(auth_hash[:extra][:access_token].params[:edam_expires].to_i)
    else
      expires_at = auth_hash[:credentials][:expires_at]
    end

    if auth_hash[:extra][:raw_info].nil?
      info = nil
    else
      info = auth_hash[:extra][:raw_info]

      case auth_hash.provider
      when 'slack'
        info.delete("ok")
        info.merge(auth_hash[:info].select { |k, v|  !v.nil? })
      when 'evernote'
        # store these per: http://discussion.evernote.com/topic/26173-is-it-safe-to-cache-the-shard-under-oauth/
        info = JSON.parse(info.to_json) # Seems to be the easiest way to make a hash of the Thrift response
        info['edam'] = {
          'noteStoreUrl'     => auth_hash[:extra][:access_token].params[:edam_noteStoreUrl],
          'webApiUrlPrefix'  => auth_hash[:extra][:access_token].params[:edam_webApiUrlPrefix]
        }
      end
    end

    {
      provider:    auth_hash[:provider],
      uid:         auth_hash[:uid],
      token:       auth_hash[:credentials][:token],
      refresh_token:  auth_hash[:credentials][:refresh_token],
      secret:      auth_hash[:credentials][:secret],
      expires_at:  expires_at,
      info:        info
    }
  end

  def sync_perms
    case provider
    when 'facebook'
      # TODO - add error checking here
      perms = api.get_object('/me/permissions').first rescue {}
      self.permissions = perms.map { |k,v| k if v == 1 }.compact
    else
      self.permissions = ['read','write']
    end
  end

  def refresh_token
    case provider
    when 'facebook'
      # exchange short lived token or expiring token for long lived
      # per: https://developers.facebook.com/roadmap/offline-access-removal/
      url = "https://graph.facebook.com/oauth/access_token"
      params = {
        :client_id      => ENV['FACEBOOK_KEY'],
        :client_secret  => ENV['FACEBOOK_SECRET'],
        :grant_type     => "fb_exchange_token",
        :fb_exchange_token => self.token
      }
      response = Typhoeus::Request.get url, :params => params
      response = CGI::parse(response.body)

      self.token = response["access_token"][0]
      self.expires_at = Time.now + response["expires"][0].to_i
    end
  end

  def expires_at=(time)
    write_attribute :expires_at, Time.at(time) rescue nil
  end

  def display_name
    case provider
    when 'slack'
      "#{info['team']} / #{info['user']}"
    else
      i = info || {}
      i['username'] || i['screen_name'] || uid
    end
  end

  def can perm
    permissions.include? perm.to_s
  end

  def api
    if @api_user.nil?
      case provider
      when 'facebook'
        @api_user = Koala::Facebook::API.new(token)
      when 'twitter'
        @api_user = Twitter::REST::Client.new do |config|
          config.consumer_key = ENV['TWITTER_KEY']
          config.consumer_secret =  ENV['TWITTER_SECRET']
          config.access_token = token
          config.access_token_secret = secret
        end
      when 'instapaper'
        Instapaper.configure do |config|
          config.consumer_key = ENV['INSTAPAPER_KEY']
          config.consumer_secret = ENV['INSTAPAPER_SECRET']
          config.oauth_token = token
          config.oauth_token_secret = secret
        end
        @api_user = Instapaper
      when 'tumblr'
        @api_user = Tumblr::Client.new do |client|
          client.consumer_key = ENV['TUMBLR_KEY']
          client.consumer_secret = ENV['TUMBLR_SECRET']
          client.oauth_token = token
          client.oauth_token_secret = secret
        end
      when 'readability'
        @api_user = Readit::API.new token, secret
      when 'evernote'
        # from: https://github.com/evernote/evernote-sdk-ruby/blob/master/sample/client/EDAMTest.rb
        noteStoreTransport = Thrift::HTTPClientTransport.new(info['edam']['noteStoreUrl'])
        noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
        @api_user = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
      when 'flattr'
        @api_user = Flattr.new :access_token => token
      when 'slack'
        @api_user = Slack::Web::Client.new token: token
      end
    end

    @api_user
  end

  def following
    case provider
    when 'twitter'
      uids = api.friend_ids.ids
    when 'facebook'
      uids = api.get_connections("me","friends").collect{|i| i["id"] }
    else
      uids = []
    end
    # the DB expects strings rather than ints
    uids = uids.collect{|i| i.to_s}
    User.where("id IN (SELECT user_id FROM authorizations WHERE provider = :provider AND uid IN (:uids))", { :provider => provider, :uids => uids })
  end
end
