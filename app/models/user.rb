class User < ActiveRecord::Base
  has_many :posts, :dependent => :destroy
  has_many :domains, :through => :posts
  has_many :hooks, :dependent => :destroy

  validates_uniqueness_of :username, :message => 'is taken'

  def to_param
    username
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      require "digest"
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.token = Digest::MD5.hexdigest(Time.new.to_s + user.uid)
    end
  end

  def first_name
    self.name.split(' ')[0]
  end

end
