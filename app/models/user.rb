class User < ActiveRecord::Base
  has_many :posts, :dependent => :destroy

  validates_uniqueness_of :username, :message => 'is taken'

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end
end
