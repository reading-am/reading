class User < ActiveRecord::Base
  has_many :authorizations, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :domains, :through => :posts
  has_many :hooks, :dependent => :destroy

  # from: http://ruby.railstutorial.org/chapters/following-users
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed

  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower

  validates_format_of     :username, :with => /^\w+[A-Z0-9]\w*$/i, :allow_nil => true
  validates_uniqueness_of :username, :message => 'is taken', :allow_nil => true
  
  before_create { generate_token(:token) }
  before_create { generate_token(:auth_token) }

  def to_param
    username
  end

  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    if auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      if auth.user_id == self.id
        # if grab whatever info that came down from the credentials this time
        # and save it if we're missing it
        # TODO - there has to be a cleaner, more concise way to do this
        auth.token  ||= auth_hash["credentials"]["token"]
        auth.secret ||= auth_hash["credentials"]["secret"]
        auth.save

        self.name       ||= auth_hash["user_info"]["name"]
        self.email      ||= auth_hash["user_info"]["email"]
        self.first_name ||= auth_hash["user_info"]["first_name"]
        self.last_name  ||= auth_hash["user_info"]["last_name"]
        self.location   ||= auth_hash["user_info"]["location"]
        self.description||= auth_hash["user_info"]["description"]
        self.image      ||= auth_hash["user_info"]["image"]
        self.phone      ||= auth_hash["user_info"]["phone"]
        self.urls       ||= auth_hash["user_info"]["urls"]
        self.save
      end
    else
      Authorization.create(
        :user       => self,
        :provider   => auth_hash["provider"],
        :uid        => auth_hash["uid"],
        :token      => auth_hash["credentials"]["token"],
        :secret     => auth_hash["credentials"]["secret"]
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
    if !self.name.nil? and self.name != ''
      self.name
    elsif !self.username.nil?
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
    Post.from_users_followed_by(self)
  end
end
