class Domain < ActiveRecord::Base
  has_many :posts
  has_many :users, :through => :posts

  def to_param
    name
  end
end
