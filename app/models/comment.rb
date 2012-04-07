class Comment < ActiveRecord::Base
  include Twitter::Extractor

  belongs_to :user
  belongs_to :post
  belongs_to :parent, :class_name => 'Comment'
  has_many   :children, :class_name => 'Comment',
    :foreign_key => :parent_id
  attr_accessible :body

  def mentioned
    extract_mentioned_screen_names body
  end
end
