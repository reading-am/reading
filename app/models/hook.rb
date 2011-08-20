class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:hipchat, :campfire, :url]
  validates_presence_of :provider, :token, :action
end
