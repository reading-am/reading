class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Twitter::Autolink

  belongs_to :user
  belongs_to :post
  belongs_to :parent, :class_name => 'Comment'
  has_many   :children, :class_name => 'Comment',
    :foreign_key => :parent_id
  attr_accessible :body

  def mentions
    extract_mentioned_screen_names body
  end

  def hashtags
    extract_hashtags body
  end

  def urls
    extract_urls body
  end

  def body_html
    auto_link(html_escape(body), {
      :url_class => '',
      :username_class => 'user',
      :username_url_base => "//#{DOMAIN}/",
      :hashtag_url_base => "//#{DOMAIN}/search?q="
    }).html_safe
  end
end
