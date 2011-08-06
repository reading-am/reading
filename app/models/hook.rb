class Hook < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = [:hipchat, :url]
end
