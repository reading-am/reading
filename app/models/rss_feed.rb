class RssFeed < ActiveRecord::Base
  attr_accessible :page_id, :url

  belongs_to :page, :counter_cache => true

  def curl=(obj)
    # this setter is used during testing
    @curl = obj
  end

  def curl
    if @curl.blank?
      @curl = Curl::Easy.new url
      @curl.follow_location = true
      @curl.perform
    end
    @curl
  end

  def remote_xml
    @remote_xml ||= Nokogiri::XML curl.body_str
  end

  def title
    @title ||= remote_xml.search("channel title").first.content
  end

  def posts
    if @posts.blank?
      @posts = []
      user = User.find(1)
      i = 1
      remote_xml.search("item").each do |item|
        post = Post.new(
          :user => user,
          :page => Page.new(
            :url => item.search("link").first.content,
            :title => item.search("title").first.content,
            :r_excerpt => item.search("description").first.content
          ),
          :created_at => Time.now,
          :updated_at => Time.now
        )
        post.id = i
        post.page.id = i
        i += 1
        @posts << post
      end
    end
    @posts
  end

end
