class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:hipchat, :campfire, :url, :opengraph]
  validates_presence_of :provider, :params

  def params
    ActiveSupport::JSON.decode(read_attribute(:params))
  end
end
