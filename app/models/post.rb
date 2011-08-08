class Post < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :page
  has_one     :domain, :through => :page
  # has_many    :referring_posts
  # has_one     :reference_post

  validates_presence_of :user, :page
end
