class Domain < ActiveRecord::Base
  has_many :posts
  has_many :users, :through => :posts
end
