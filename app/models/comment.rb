class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Twitter::Autolink

  belongs_to :user, :counter_cache => true
  belongs_to :page, :counter_cache => true
  belongs_to :post
  belongs_to :parent, :class_name => 'Comment'
  has_many   :children, :class_name => 'Comment',
    :foreign_key => :parent_id

  validates_presence_of :user, :page, :body

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

  def simple_obj to_s=false
    {
      :type   => "Comment",
      :id     => to_s ? id.to_s : id,
      :body   => body,
      :created_at => created_at,
      :updated_at => updated_at,
      :user   => user.simple_obj
    }
  end
end
