class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :parent, :class_name => 'Comment'
  has_many   :children, :class_name => 'Comment',
    :foreign_key => :parent_id
  attr_accessible :body
end
