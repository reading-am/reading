# from: http://net.tutsplus.com/tutorials/ruby/how-to-use-omniauth-to-authenticate-your-users/
class Authorization < ActiveRecord::Base
  belongs_to :user
  validates :provider, :uid, :presence => true

  def self.find_or_create(auth_hash)
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      user = User.create(
        :name       => auth_hash["user_info"]["name"],
        :email      => auth_hash["user_info"]["email"],
        # check to make sure a user doesn't already have that nickname
        :username   => !User.find_by_username(auth_hash["user_info"]["nickname"]) ? auth_hash["user_info"]["nickname"] : nil,
        :first_name => auth_hash["user_info"]["first_name"],
        :last_name  => auth_hash["user_info"]["last_name"],
        :location   => auth_hash["user_info"]["location"],
        :description=> auth_hash["user_info"]["description"],
        :image      => auth_hash["user_info"]["image"],
        :phone      => auth_hash["user_info"]["phone"],
        :urls       => auth_hash["user_info"]["urls"]
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
