module ApplicationHelper
  def og_tags hash={}
    og = {
      :type   => "website",
      :title  => "something",
      :description => "What you're reading. Not what you like. Not what you find interesting. Just what you're reading.",
      :image  => "apple-touch-icon.png"
    }
    og = og.merge(hash)
    og.collect {|k,v| "<meta property=\"og:#{k}\" content=\"#{v}\" />\n" if v }.join.html_safe
  end
end
