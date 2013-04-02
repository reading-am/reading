module PostsHelper

  def page_hashes_from_posts posts
    _pages = []
    date = ''
    posts.group_by(&:page).each_with_index do |(page, subposts), i|
      _page = page.simple_obj
      _page[:url] = subposts.first.wrapped_url
      _page[:posts] = []

      if date != subposts.first.created_at.strftime("%m/%d")
        _page[:date] = date = subposts.first.created_at.strftime("%m/%d")
      else
        yn_avg = yn_average subposts
        if yn_avg > 0
          _page[:yn_class] = "yep"
          _page[:yep] = true
        elsif yn_avg < 0
          _page[:yn_class] = "nope"
          _page[:nope] = true
        end
      end

      subposts.each do |post|
        _post = post.simple_obj

        _post[:yep] = post.yn === true
        _post[:nope] = post.yn === false

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

  def export_posts_to_csv posts
    require 'csv'
    CSV.generate(:headers => :first_row) do |csv|
      csv << ["URL","Title","Date Posted", "Yep / Nope"]
      posts.find_each do |post|
        csv << [post.page.url, post.page.title, post.created_at, post.yn.nil? ? nil : post.yn ? "yep" : "nope"]
      end
    end
  end

end
