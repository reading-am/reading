class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:hipchat, :url]
  validates_presence_of :provider, :token, :action
end
