class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:hipchat, :campfire, :url]
  validates_presence_of :provider, :token, :action

  def params
    ActiveSupport::JSON.decode(read_attribute(:params))
  end
end
