class Post < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :domain
  # has_many    :referring_posts
  # has_one     :reference_post

  validates_presence_of :user, :domain, :url
end
