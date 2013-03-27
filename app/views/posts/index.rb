# encoding: utf-8
module Posts
  class Index < ::Stache::Mustache::View

    def pages
      _pages = []
      date = ''
      posts.group_by(&:page).each_with_index do |(page, subposts), i|
        subposts.reverse!

        _page = page.simple_obj
        _page[:url] = subposts.first.wrapped_url
        _page[:posts] = []

        if date != subposts.last.created_at.strftime("%m/%d")
          _page[:date] = date = subposts.last.created_at.strftime("%m/%d")
        else
          yn_avg = yn_average subposts
          if yn_avg > 0
            _page[:yn_class] = "yep"
            _page[:yepped] = true
          elsif yn_avg < 0
            _page[:yn_class] = "nope"
            _page[:noped] = true
          end
        end

        subposts.each do |post|
          _post = post.simple_obj

          _post[:user][:size] = "small"
          _post[:user].delete(:username)
          _post[:user].delete(:bio)

          _page[:posts] << _post
        end
        _page[:has_comments] = _page[:comments_count] > 0
        _pages << _page
      end
      _pages
    end

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
