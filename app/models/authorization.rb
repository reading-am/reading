# from: http://net.tutsplus.com/tutorials/ruby/how-to-use-omniauth-to-authenticate-your-users/
class Authorization < ActiveRecord::Base
  belongs_to :user
  has_many :hooks, :dependent => :destroy

  PROVIDERS = ['twitter','facebook','instapaper','readability','tumblr','evernote','tssignals','kippt']
  validates :provider, :uid, :presence => true
  before_create :set_initial_perms

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
      info = Yajl::Parser.parse(auth_hash[:extra][:raw_info].to_json)

      case auth_hash.provider
      when 'evernote'
        # store these per: http://discussion.evernote.com/topic/26173-is-it-safe-to-cache-the-shard-under-oauth/
        info[:edam] = {
          :noteStoreUrl     => auth_hash[:extra][:access_token].params[:edam_noteStoreUrl],
          :webApiUrlPrefix  => auth_hash[:extra][:access_token].params[:edam_webApiUrlPrefix]
        }
      end

      info = info.to_json
    end

    {
      :provider   => auth_hash[:provider],
      :uid        => auth_hash[:uid],
      :token      => auth_hash[:credentials][:token],
      :refresh_token => auth_hash[:credentials][:refresh_token],
      :secret     => auth_hash[:credentials][:secret],
      :expires_at => expires_at,
      :info       => info
    }
  end

  def sync_perms
    case provider
    when 'facebook'
      # TODO - add error checking here
      perms = api.get_object('/me/permissions').first rescue {}
      perms = perms.map { |k,v| k if v == 1 }.compact.join('","')
      self.permissions = perms.blank? ? "[]" : "[\"#{perms}\"]"
    else
      self.permissions = '["read","write"]'
    end
  end

  def refresh_token
    case provider
    when 'facebook'
      # exchange short lived token or expiring token for long lived
      # per: https://developers.facebook.com/roadmap/offline-access-removal/
      url = "https://graph.facebook.com/oauth/access_token"
      params = {
        :client_id      => ENV['READING_FACEBOOK_KEY'],
        :client_secret  => ENV['READING_FACEBOOK_SECRET'],
        :grant_type     => "fb_exchange_token",
        :fb_exchange_token => self.token
      }
      response = Typhoeus::Request.get url, :params => params
      response = CGI::parse(response.body)

      self.token = response["access_token"][0]
      self.expires_at = Time.now + response["expires"][0].to_i
    end
  end

  def permissions
    Yajl::Parser.parse(read_attribute(:permissions)) unless read_attribute(:permissions).nil?
  end

  def info
    Yajl::Parser.parse(read_attribute(:info)) unless read_attribute(:info).nil?
  end

  def display_name
    case provider
    when 'tssignals'
      accounts.first["name"]
    else
      (info.blank? or info['username'].blank?) ? uid : info['username']
    end
  end

  def accounts
    case provider
    when "tssignals"
      info["accounts"].find_all{|a| a["product"] == "campfire"}
    end
  end

  def can perm
    permissions.include? perm.to_s
  end

  def add_perm perm
    unless can perm
      self.permissions = (permissions << perm).to_json
    end
  end

  def remove_perm perm
    if can perm
      self.permissions = (permissions.delete_if { |v| v == perm.to_s }).to_json
    end
  end

  def api
    if @api_user.nil?
      case provider
      when 'facebook'
        @api_user = Koala::Facebook::API.new(token)
      when 'twitter'
        @api_user = Twitter::Client.new(:oauth_token => token, :oauth_token_secret => secret) rescue nil
      when 'instapaper'
        Instapaper.configure do |config|
          config.consumer_key = ENV['READING_INSTAPAPER_KEY']
          config.consumer_secret = ENV['READING_INSTAPAPER_SECRET']
          config.oauth_token = token
          config.oauth_token_secret = secret
        end
        @api_user = Instapaper
      when 'tumblr'
        @api_user = Tumblr::Client.new do |client|
          client.consumer_key = ENV['READING_TUMBLR_KEY']
          client.consumer_secret = ENV['READING_TUMBLR_SECRET']
          client.oauth_token = token
          client.oauth_token_secret = secret
        end
      when 'readability'
        @api_user = Readit::API.new token, secret
      when 'evernote'
        client = EvernoteOAuth::Client.new token: token
        @api_user = client.note_store :note_store_url => info['edam']['noteStoreUrl']
      when 'tssignals'
        account = accounts.first
        @api_user = Tinder::Campfire.new URI.parse(account['href']).host.split('.')[0], :token => account['api_auth_token']
      when 'kippt'
        @api_user = Kippt::Client.new(username: info['username'], token: token)
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

  def simple_obj to_s=false
    {
      :type         => 'Authorization',
      :provider     => provider,
      :uid          => to_s ? uid.to_s : uid,
      :permissions  => permissions,
      :info         => provider == 'tssignals' ? accounts.first : info,
      :created_at   => created_at,
      :updated_at   => updated_at
    }
  end

end
