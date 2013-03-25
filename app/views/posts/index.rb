module Posts 
  class Index < ::Stache::Mustache::View

    def pagination
      will_paginate @posts, :page_links => false
    end

    def link_to_rss
      link_to rss_path, {:class => 'rss'} do
        '<span class="glyph">r</span> rss'.html_safe
      end
    end

    def show_blank_slate
      user.posts.size == 0 or user.following.size == 0
    end

    # CARD

    def avatar_html
      has_avatar = user != current_user or (user == current_user and !user.avatar.size.nil?)
      avatar_url = has_avatar ? user.avatar.url : "/settings/info"
      avatar_target = has_avatar ? "_blank" : nil
      link_to avatar_url, :id => "avatar", :class => "span1", :target => avatar_target do
        image_tag user.avatar.url :medium
      end
    end

    def is_current_user
      user == current_user
    end

    def follow_text
      current_user.following?(user) ? 'unfollow' : 'follow'
    end

    def follow_text_capitalized
      follow_text.capitalize
    end

    def viewing_following
      params[:type] == 'following'
    end

    def viewing_followers
      params[:type] == 'followers'
    end

    # YOU SUBNAV

    def you_or_name
      user == current_user ? 'you' : user.first_name
    end

    def viewing_posts
      params[:type] == 'posts'
    end

    def viewing_list
      params[:type] == 'list'
    end

    # BLANKSLATE

    def extension_install_html
      if browser.chrome?
        extension_install :chrome, 'Install Chrome Extension'
      elsif browser.safari?
        extension_install :safari, 'Install Safari Extension'
      elsif browser.firefox?
        extension_install :firefox, 'Install Firefox Extension'
      end
    end

    def extension_install_chrome
      extension_install :chrome
    end

    def extension_install_safari
      extension_install :safari
    end

    def extension_install_firefox
      extension_install :firefox
    end

    def bookmarklet_url
      bookmarklet_url(current_user)
    end

  end
end
