class User < ActiveRecord::Base
  has_many :posts, :dependent => :destroy
  has_many :domains, :through => :posts
  has_many :hooks, :dependent => :destroy

  validates_format_of     :username, :with => /^\w+[A-Z0-9]\w*$/i, :allow_nil => true
  validates_uniqueness_of :username, :message => 'is taken', :allow_nil => true
  
  before_create { generate_token(:token) }
  before_create { generate_token(:auth_token) }

  def to_param
    username
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      require "digest"
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def first_name
    self.name.split(' ')[0] if self.name
  end

  def display_name
    self.name || self.username
  end
end
