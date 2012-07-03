# from: http://net.tutsplus.com/tutorials/ruby/how-to-use-omniauth-to-authenticate-your-users/
class Authorization < ActiveRecord::Base
  belongs_to :user
  has_many :hooks, :dependent => :destroy

  PROVIDERS = ['twitter','facebook','instapaper','readability','tumblr']
  validates :provider, :uid, :presence => true
  before_create :set_initial_perms

private

  def set_initial_perms
    self.sync_perms if self.permissions.nil?
  end

public

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
    (info.blank? or info['username'].blank?) ? uid : info['username']
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
      end
    end

    @api_user
  end

  def self.find_or_create(auth_hash)
    if auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      # fill in any changed info
      ["token","secret","expires_at"].each do |prop|
        auth[prop] = auth_hash["credentials"][prop] || auth[prop]
      end
      auth.save
    else
      username = auth_hash["info"]["nickname"]
      username = (username.nil? or username == '') ? nil : username.gsub(/[^A-Z0-9_]/i, '')
      user = User.create(
        :name       => auth_hash["info"]["name"],
        :email      => auth_hash["info"]["email"],
        # check to make sure a user doesn't already have that nickname
        :username   => (username.nil? or User.find_by_username(username)) ? nil : username,
        :first_name => auth_hash["info"]["first_name"],
        :last_name  => auth_hash["info"]["last_name"],
        :location   => auth_hash["info"]["location"],
        :description=> auth_hash["info"]["description"],
        :image      => auth_hash["info"]["image"],
        :phone      => auth_hash["info"]["phone"],
        :urls       => auth_hash["info"]["urls"]
      )
      # account for facebook usernames with periods and the like
      unless user.errors.messages[:username].nil?
        user.username = nil
        user.save
      end
      # account for bad email addresses coming from provider
      unless user.errors.messages[:email].nil?
        user.email = nil
        user.save
      end
      auth = create(
        :user       => user,
        :provider   => auth_hash["provider"],
        :uid        => auth_hash["uid"],
        :token      => auth_hash["credentials"]["token"],
        :secret     => auth_hash["credentials"]["secret"],
        :expires_at => auth_hash["credentials"]["expires_at"],
        :info       => auth_hash['extra']['raw_info'].nil? ? nil : auth_hash['extra']['raw_info'].to_json
      )

      # Auto-follow everyone from their social network
      auth.following.each do |u|
        user.follow!(u)
      end
    end

    auth
  end

  def following
    case provider
    when 'twitter'
      uids = api.friend_ids.ids
    when 'facebook'
      uids = api.get_connections("me","friends").collect{|i| i["id"] }
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
      :info         => info,
      :created_at   => created_at,
      :updated_at   => updated_at
    }
  end

end
