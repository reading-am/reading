class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  attr_accessor :email_required, :password_required

  bitmask :roles, :as => [
    :admin
  ]

  bitmask :access, :as => [
    :digest,
    :tagalong,
    :comments,
    :media_feed,
    :tumblr_templates
  ]

  serialize :urls, JSON


  has_many :oauth_access_tokens, class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id
  has_many :oauth_client_apps, class_name: 'Doorkeeper::Application', through: :oauth_access_tokens, source: :application
  has_many :oauth_owner_apps, class_name: 'Doorkeeper::Application', as: :owner

  has_many :authorizations, -> { includes [:user] }, dependent: :destroy # also handled by foreign key
  has_many :posts, -> { includes [:user, :page, :domain, {:referrer_post => :user}] }, dependent: :destroy # also handled by foreign key
  has_many :domains, through: :posts
  has_many :hooks, -> { includes [:user, :authorization] }, dependent: :destroy # handled by foreign key
  has_many :pages, through: :posts
  has_many :comments, dependent: :destroy # also handled by foreign key

  # from: http://ruby.railstutorial.org/chapters/following-users
  has_many :relationships, foreign_key: "follower_id",
                           dependent: :destroy # also handled by foreign key
  has_many :following, through: :relationships, source: :followed

  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship",
                                   dependent: :destroy # also handled by foreign key
  has_many :followers, through: :reverse_relationships, source: :follower

  has_many :blogs, dependent: :destroy # also handled by foreign key

  has_attached_file :avatar,
    :styles => {
      :mini => "25x25>",
      :thumb => "70x70>",
      :medium => "140x140>",
      :large => "500x500>"
    },
    :default_url => "#{ROOT_URL}/assets/users/:attachment/default_:style.png"

  validates_attachment :avatar,
    :size => { :less_than => 2.megabytes },
    :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  validates_format_of     :username, :with => /\A\w+[A-Z0-9]\w*\z/i, :allow_nil => true
  validates_uniqueness_of :username, :message => 'is taken', :allow_nil => true, :case_sensitive => false
  validates :bio, :length => { :maximum => 255 }
  validates_format_of     :link, :with => URI::regexp(%w(http https)), :allow_blank => true

  nilify_blanks :only => [:email]

  before_create { generate_token(:token) }

  scope :only_follows, lambda { |user| follows(user) }
  scope :who_posted_to, lambda { |page| posted_to(page) }
  scope :digesting_on_day, lambda { |freq| digesting(freq) }

  # Search
  include Elasticsearch::Model
  after_create  { SearchIndexJob.new.async.perform(:create,  self) }
  after_update  { SearchIndexJob.new.async.perform(:update,  self) }
  after_destroy { SearchIndexJob.new.async.perform(:destroy, self) }
  def as_indexed_json(options={})
    as_json(only: [:name, :username, :email, :link])
  end

  private

  def self.posted_to page
    where("id IN (SELECT posts.user_id FROM posts WHERE posts.page_id = :page_id)", {:page_id => page})
  end

  def self.follows user
    where("id IN (SELECT followed_id FROM relationships WHERE follower_id = :user_id)",
          {:user_id => user})
  end

  def self.digesting freq
    where("email IS NOT NULL AND mail_digest IN (:freq)", { :freq => freq })
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

  def self.transform_auth_hash auth_hash
    username = auth_hash["info"]["nickname"]
    username = username.blank? ? nil : username.gsub(/[^A-Z0-9_]/i, '')
    username = username.blank? ? nil : username

    {
      username:    username,
      name:        auth_hash["info"]["name"],
      email:       auth_hash["info"]["email"],
      first_name:  auth_hash["info"]["first_name"],
      last_name:   auth_hash["info"]["last_name"],
      location:    auth_hash["info"]["location"],
      description: auth_hash["info"]["description"],
      image:       auth_hash["info"]["image"],
      phone:       auth_hash["info"]["phone"],
      urls:        auth_hash["info"]["urls"]
    }
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
    "#{ROOT_URL}/#{username}"
  end

  def following?(followed)
    id == followed.id ? true : relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(followed_id: followed.id) unless id == followed.id
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy unless id == followed.id
  end

  def feed
    Post.from_users_followed_by(self)
  end

  def unread_since(datetime)
    Post.unread_by_since(self, datetime).includes(:user, :page, {referrer_post: :user})
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

  def is_adhoc?
    username.blank?
  end

  def suspended?
    status == 1
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
    base = "https://s3.amazonaws.com/#{ENV['READING_S3_BUCKET']}/users/avatars"
    if avatar_file_name.blank?
      "#{base}/default/#{style}.png"
    else
      "#{base}/#{sprintf('%09d', id).gsub(/(\d{3})(?=\d)/, '\\1/')}/#{style}/#{avatar_file_name}?#{avatar_updated_at.to_time.to_i}"
    end
  end

  def simple_obj to_s=false
    {
      type:         'User',
      id:           to_s ? id.to_s : id,
      url:          url,
      username:     username,
      display_name: display_name,
      first_name:   first_name,
      full_name:    name,
      bio:          bio,
      link:         link,
      location:     location,
      avatar:       avatar_url,
      avatar_medium:   avatar_url(:medium),
      avatar_thumb:    avatar_url(:thumb),
      avatar_mini:     avatar_url(:mini),
      posts_count:     posts.size,
      following_count: following.size,
      followers_count: followers.size,
      access:     access,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
