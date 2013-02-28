module PostsHelper

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
