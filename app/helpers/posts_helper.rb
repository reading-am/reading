module PostsHelper

  def medium_to_object medium
    {
      'all'   => 'stuff',
      'text'  => 'stuff',
      'image' => 'images',
      'video' => 'videos',
      'audio' => 'audio'
    }[medium] || 'stuff'
  end

  def medium_to_verb medium
    {
      'all'   => 'reading',
      'text'  => 'reading',
      'image' => 'looking at',
      'video' => 'watching',
      'audio' => 'listening to'
    }[medium] || 'reading'
  end

  def page_hashes_from_posts(posts)
    _pages = []
    date = ''
    posts.group_by(&:page).each_with_index do |(page, subposts), i|
      _page = render_api partial: 'pages/page', page: page
      _page['url'] = subposts.first.wrapped_url
      _page['posts'] = []

      if date != subposts.first.created_at.strftime('%m/%d')
        _page['date'] = date = subposts.first.created_at.strftime('%m/%d')
      else
        yn_avg = yn_average subposts
        if yn_avg > 0
          _page['yn_class'] = 'yep'
          _page['yep'] = true
        elsif yn_avg < 0
          _page['yn_class'] = 'nope'
          _page['nope'] = true
        end
      end

      subposts.each do |post|
        _post = render_api partial: 'posts/post', post: post

        _post['yep'] = post.yn === true
        _post['nope'] = post.yn === false

        _post['page']['verb'] = page.verb

        _post['user']['avatar'] = _post['user']['avatar_thumb']
        _post['user'].delete('username')
        _post['user'].delete('bio')

        if post.referrer_post_id
          _post['referrer_post']['user']['avatar'] = _post['referrer_post']['user']['avatar_thumb']
          _post['referrer_post']['user'].delete('username')
          _post['referrer_post']['user'].delete('bio')
        else
          _post.delete('referrer_post')
        end

        _page['posts'] << _post
      end

      _page['has_comments'] = _page['comments_count'] > 0
      _page['access_page_permalinks'] = signed_in? && current_user.access?(:page_permalinks)

      _pages << _page
    end
    _pages
  end

  # adapted from: http://rubyglasses.blogspot.com/2008/10/enumerableaverage.html
  def yn_average(posts)
    the_sum = 0
    total_count = 0
    posts.each do |post|
      if post.yn.nil?
        next_value = 0
      else
        next_value = post.yn ? 1 : -1
      end
      the_sum += next_value
      total_count += 1
    end
    return 0 unless total_count > 0
    the_sum / total_count
  end

end
