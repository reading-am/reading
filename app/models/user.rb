class User < ActiveRecord::Base
  bitmask :access, :as => [
    :digest,
    :tagalong,
    :comments
  ]

  has_many :authorizations, :dependent => :destroy
  has_many :posts, :dependent => :destroy, :include => [:user, :page, :domain, {:referrer_post => :user}]
  has_many :domains, :through => :posts
  has_many :hooks, :dependent => :destroy
  has_many :pages, :through => :posts
  has_many :comments, :dependent => :destroy

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
      :medium => "140x140>",
      :large => "500x500>"
    },
    :default_url => "//#{DOMAIN}/assets/users/:attachment/default_:style.png",
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
  validates_uniqueness_of :username, :message => 'is taken', :allow_nil => true, :case_sensitive => false
  validates :email, :email => {:allow_nil => true}
  validates_uniqueness_of :email, :allow_nil => true, :case_sensitive => false
  validates :bio, :length => { :maximum => 255 }
  validates_format_of     :link, :with => URI::regexp(%w(http https)), :allow_blank => true

  before_create { generate_token(:token) }
  before_create { generate_token(:auth_token) }

  scope :only_follows, lambda { |user| follows(user) }
  scope :who_posted_to, lambda { |page| posted_to(page) }
  scope :digesting_on_day, lambda { |freq| digesting(freq) }
  scope :mentioned_in, lambda { |comment| mentioned(comment) }

  searchable do
    text :name, :username, :email, :link
  end
  handle_asynchronously :solr_index

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

  def self.mentioned comment
    where("username IN (:mentions)", { :mentions => comment.mentions })
  end

  public

  def to_param
    username
  end

  def self.find_by_username(username)
    where("lower(username) = ?", username.downcase).first
  end

  # TODO - consolidate most of this logic with Authorization#find_or_create
  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    if auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"].to_s)
      if auth.user_id != self.id
        raise AuthError.new("AuthTaken")
      end
      # grab whatever info that came down from the credentials this time
      # and save it if we're missing it
      ["token","secret","expires_at"].each do |prop|
        auth[prop] = auth_hash["credentials"][prop] || auth[prop]
      end
      auth.save

      [
        "name",
        "email",
        "first_name",
        "last_name",
        "location",
        "description",
        "image",
        "phone",
        "urls"
      ].each do |prop| self[prop] ||= auth_hash["info"][prop] end
      self.save

      raise AuthError.new("AuthPreexisting", auth)
    else
      Authorization.create(
        :user       => self,
        :provider   => auth_hash["provider"],
        :uid        => auth_hash["uid"],
        :token      => auth_hash["credentials"]["token"],
        :secret     => auth_hash["credentials"]["secret"],
        :expires_at => auth_hash["credentials"]["expires_at"],
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
    if !name.blank?
      name
    elsif !username.blank?
      username
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

  # is an original user who didn't require an email address to register
  def is_og?
    created_at < Date.parse('2012-07-17')
  end

  def simple_obj to_s=false
    {
      :type       => 'User',
      :id         => to_s ? id.to_s : id,
      :username   => username,
      :display_name => display_name,
      :first_name => first_name,
      :full_name  => name,
      :bio        => bio,
      :url        => "http://#{DOMAIN}/#{username}",
      :avatar     => avatar.url,
      :avatar_medium => avatar.url(:medium),
      :avatar_thumb => avatar.url(:thumb),
      :avatar_mini  => avatar.url(:mini),
      :following_count => following.size,
      :followers_count => followers.size,
      :created_at => created_at,
      :udpated_at => updated_at,
      :can_comment => access?(:comments) # TODO remove once comments are public
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
