class User < ActiveRecord::Base
  bitmask :access, :as => [:digest]

  has_many :authorizations, :dependent => :destroy
  has_many :posts, :dependent => :destroy, :include => [:user, :page, :domain, {:referrer_post => :user}]
  has_many :domains, :through => :posts
  has_many :hooks, :dependent => :destroy
  has_many :pages, :through => :posts

  # from: http://ruby.railstutorial.org/chapters/following-users
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed

  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower

  has_attached_file :avatar,
    :styles => {
      :mini => "25x25>",
      :thumb => "70x70>",
      :large => "500x500>"
    },
    :default_url => '/assets/users/:attachment/default_:style.png',
    :storage => :s3,
    :s3_protocol => 'https',
    :bucket => "reading-#{Rails.env}",
    :s3_credentials => {
      :access_key_id => ENV['READING_S3_KEY'],
      :secret_access_key => ENV['READING_S3_SECRET']
    }
  validates_attachment_size :avatar, :less_than=>2.megabytes
  validates_attachment_content_type :avatar, :content_type=>['image/jpeg', 'image/png', 'image/gif']

  validates_format_of     :username, :with => /^\w+[A-Z0-9]\w*$/i, :allow_nil => true
  validates_uniqueness_of :username, :message => 'is taken', :allow_nil => true
  validates :email, :email => {:allow_blank => true}, :uniqueness => true, :allow_nil => true
  validates :bio, :length => { :maximum => 255 }
  validates_format_of     :link, :with => URI::regexp(%w(http https)), :allow_blank => true

  before_create { generate_token(:token) }
  before_create { generate_token(:auth_token) }

  scope :find_by_username, lambda { |username| where("lower(username) = ?", username.downcase).limit(1) }
  scope :only_follows, lambda { |user| follows(user) }
  scope :who_posted_to, lambda { |page| posted_to(page) }
  scope :digesting_on_day, lambda { |freq| digesting(freq) }

  private

  def self.posted_to page
    where("id IN (SELECT user_id FROM posts WHERE posts.page_id = :page_id)", { :page_id => page })
  end

  def self.follows user
    where("id IN (SELECT followed_id FROM relationships WHERE follower_id = :user_id)",
          { :user_id => user})
  end

  def self.digesting freq
    where("email IS NOT NULL AND mail_digest IN (:freq)", { :freq => freq })
  end

  public

  def to_param
    username
  end

  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    if auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"].to_s)
      if auth.user_id != self.id
        raise AuthError.new("AuthTaken")
      end
      # grab whatever info that came down from the credentials this time
      # and save it if we're missing it
      # TODO - there has to be a cleaner, more concise way to do this
      auth.token  ||= auth_hash["credentials"]["token"]
      auth.secret ||= auth_hash["credentials"]["secret"]
      auth.sync_perms # make sure the permissions stay in sync
      auth.save

      self.name       ||= auth_hash["info"]["name"]
      self.email      ||= auth_hash["info"]["email"]
      self.first_name ||= auth_hash["info"]["first_name"]
      self.last_name  ||= auth_hash["info"]["last_name"]
      self.location   ||= auth_hash["info"]["location"]
      self.description||= auth_hash["info"]["description"]
      self.image      ||= auth_hash["info"]["image"]
      self.phone      ||= auth_hash["info"]["phone"]
      self.urls       ||= auth_hash["info"]["urls"]
      self.save
      raise AuthError.new("AuthPreexisting", auth)
    else
      Authorization.create(
        :user       => self,
        :provider   => auth_hash["provider"],
        :uid        => auth_hash["uid"],
        :token      => auth_hash["credentials"]["token"],
        :secret     => auth_hash["credentials"]["secret"],
        :info       => auth_hash['extra']['raw_info'].nil? ? nil : auth_hash['extra']['raw_info'].to_json
      )
    end
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def first_name
    self.name ? self.name.split(' ')[0] : self.username
  end

  def display_name
    if !self.name.blank?
      self.name
    elsif !self.username.blank?
      self.username
    else
      'Anonymous'
    end
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def feed
    Post.from_users_followed_by(self).includes([:user, :page, :domain, {:referrer_post => :user}])
  end

  def unread_since(datetime)
    Post.unread_by_since(self, datetime).includes([:user, :page, :domain, {:referrer_post => :user}])
  end

  def following_who_posted_to page
    User.who_posted_to(page).only_follows(self)
  end

  def simple_obj to_s=false
    {
      :type       => 'User',
      :id         => to_s ? id.to_s : id,
      :username   => username,
      :display_name => display_name
    }
  end
end

class AuthError < StandardError
  # per: http://jqr.github.com/2009/02/11/passing-data-with-ruby-exceptions.html
  attr_accessor :auth

  def initialize(message = nil, auth = nil)
    super(message)
    self.auth = auth
  end
end
