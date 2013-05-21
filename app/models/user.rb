class User < ActiveRecord::Base
  #include IdentityCache
  def self.fetch(*args)
    self.send(:find, *args)
  end
  def self.fetch_by_token(*args)
    self.send(:fetch_by_token, *args)
  end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  attr_accessible :username, :email, :password, :password_confirmation,
                  :remember_me, :name, :first_name, :last_name, :location,
                  :bio, :link, :phone, :urls, :description, :mail_digest,
                  :email_when_followed, :email_when_mentioned, :avatar

  attr_accessor :email_required, :password_required

  bitmask :roles, :as => [
    :admin
  ]

  bitmask :access, :as => [
    :digest,
    :tagalong,
    :comments
  ]

  has_many :authorizations, :dependent => :destroy, :include => [:user]
  has_many :posts, :dependent => :destroy, :include => [:user, :page, :domain, {:referrer_post => :user}]
  has_many :domains, :through => :posts
  has_many :hooks, :dependent => :destroy, :include => [:user, :authorization]
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

  #cache_index :token, :unique => true

  has_attached_file :avatar,
    :styles => {
      :mini => "25x25>",
      :thumb => "70x70>",
      :medium => "140x140>",
      :large => "500x500>"
    },
    :default_url => "http#{Rails.env == 'production' ? 's' : ''}://#{DOMAIN}/assets/users/:attachment/default_:style.png"

  validates_attachment :avatar,
    :size => { :less_than => 2.megabytes },
    :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  validates_format_of     :username, :with => /^\w+[A-Z0-9]\w*$/i, :allow_nil => true
  validates_uniqueness_of :username, :message => 'is taken', :allow_nil => true, :case_sensitive => false
  validates :email, :email => {:allow_nil => true}
  validates_uniqueness_of :email, :allow_nil => true, :case_sensitive => false
  validates :bio, :length => { :maximum => 255 }
  validates_format_of     :link, :with => URI::regexp(%w(http https)), :allow_blank => true

  nilify_blanks :only => [:email]

  before_create { generate_token(:token) }

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
    where("lower(username) IN (:mentions)", { :mentions => comment.mentions.map{|u| u.downcase }})
  end

  # For Devise so that we can register people via Omniauth,
  # save their Auth and User, then ask for additional info.
  def email_required?
    if email_required.nil? then super else email_required end
  end

  def password_required?
    if password_required.nil? then super else password_required end
  end

  public

  def to_param; username; end

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  # via: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  attr_accessor :login
  attr_accessible :login
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.find_by_username(username)
    where("lower(username) = ?", username.downcase).limit(1).first
  end

  # TODO - consolidate most of this logic with Authorization#find_or_create
  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    if auth = Authorization.fetch_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"].to_s)
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
      auth_params = Authorization::transform_auth_hash(auth_hash)
      auth_params[:user] = self
      auth = Authorization.create auth_params
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

  def url
    "http://#{DOMAIN}/#{username}"
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
    Post.from_users_followed_by(self).includes([:user, :page, {:referrer_post => :user}])
  end

  def unread_since(datetime)
    Post.unread_by_since(self, datetime).includes([:user, :page, {:referrer_post => :user}])
  end

  def following_who_posted_to page
    User.who_posted_to(page).only_follows(self)
  end

  # is an original user who didn't require an email address to register
  def joined_before_email?
    !created_at.blank? && created_at < Date.parse('2012-07-17')
  end

  def joined_before_passwords?
    !created_at.blank? && created_at < Date.parse('2012-12-16')
  end

  def has_pass?
    !encrypted_password_was.blank?
  end

  def channels
    [
      "users"
    ]
  end

  # Modified from Devise to allow for modification of empty passwords
  # https://github.com/plataformatec/devise/blob/master/lib/devise/models/database_authenticatable.rb#L56
  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if valid_password?(current_password) || !has_pass?
      update_attributes(params, *options)
    else
      params.delete(:password)
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end

  def avatar_url style=:original
    # URL generation through the paperclip gem is slooowwwww. This is a swifter workaround.
    # https://github.com/thoughtbot/paperclip/issues/909
    if avatar_file_name.blank?
      "http#{Rails.env == 'production' ? 's' : ''}://#{DOMAIN}/assets/users/avatars/default_#{style}.png"
    else
      "https://s3.amazonaws.com/#{ENV['READING_S3_BUCKET']}/users/avatars/#{sprintf('%09d', id).gsub(/(\d{3})(?=\d)/, '\\1/')}/#{style}/#{avatar_file_name}?#{avatar_updated_at.to_time.to_i}"
    end
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
      :url        => url,
      :avatar     => avatar_url,
      :avatar_medium => avatar_url(:medium),
      :avatar_thumb => avatar_url(:thumb),
      :avatar_mini  => avatar_url(:mini),
      :following_count => following.size,
      :followers_count => followers.size,
      :created_at => created_at,
      :updated_at => updated_at
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
