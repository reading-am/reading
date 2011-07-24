class User < ActiveRecord::Base

  validates_uniqueness_of :invitation_id, :on => :create, :message => 'has already been used'

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end
end
