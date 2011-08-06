class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :domain

  validates_presence_of :user, :domain, :url
end
