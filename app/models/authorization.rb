# from: http://net.tutsplus.com/tutorials/ruby/how-to-use-omniauth-to-authenticate-your-users/
class Authorization < ActiveRecord::Base
  belongs_to :user
  has_many :hooks, :dependent => :destroy

  PROVIDERS = [:twitter, :facebook]
  validates :provider, :uid, :presence => true
  before_create :set_default_perms

  def set_default_perms
    if self.permissions.nil?
      # these should mirror what's in config/initializers/omniauth.rb
      case self.provider
      when 'twitter'
        self.permissions = '["read","write"]'
      when 'facebook'
        self.permissions = '["email","offline_access"]'
      end
    end
  end

  def permissions
    ActiveSupport::JSON.decode(read_attribute(:permissions)) if !read_attribute(:permissions).nil?
  end

  def api
    #via: http://blog.assimov.net/post/2358661274/twitter-integration-with-omniauth-and-devise-on-rails-3
    case provider
    when 'facebook'
      @api_user ||= Koala::Facebook::API.new(token)
    when 'twitter'
      @api_user ||= Twitter::Client.new(:oauth_token => token, :oauth_token_secret => secret) rescue nil
    end
  end

  def self.find_or_create(auth_hash)
    if auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      # fill in any missing info
      # There was a point where we weren't collecting
      # tokens and secrets. This backfills them
      auth.token  ||= auth_hash["credentials"]["token"]
      auth.secret ||= auth_hash["credentials"]["secret"]
      auth.save if auth.changed?
    else
      user = User.create(
        :name       => auth_hash["info"]["name"],
        :email      => auth_hash["info"]["email"],
        # check to make sure a user doesn't already have that nickname
        :username   => !User.find_by_username(auth_hash["info"]["nickname"]) ? auth_hash["info"]["nickname"] : nil,
        :first_name => auth_hash["info"]["first_name"],
        :last_name  => auth_hash["info"]["last_name"],
        :location   => auth_hash["info"]["location"],
        :description=> auth_hash["info"]["description"],
        :image      => auth_hash["info"]["image"],
        :phone      => auth_hash["info"]["phone"],
        :urls       => auth_hash["info"]["urls"]
      )
      auth = create(
        :user       => user,
        :provider   => auth_hash["provider"],
        :uid        => auth_hash["uid"],
        :token      => auth_hash["credentials"]["token"],
        :secret     => auth_hash["credentials"]["secret"]
      )
    end

    auth
  end
end
