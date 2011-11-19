# encoding: utf-8
module ApplicationHelper
  def og_tags hash={}
    og = {
      :type   => "website",
      :title  => "✌ Reading",
      :description => "What you're reading. Not what you like. Not what you find interesting. Just what you're reading.",
      :image  => "apple-touch-icon.png"
    }
    og = og.merge(hash)
    og.collect {|k,v| "<meta property=\"og:#{h(k)}\" content=\"#{h(v)}\" />\n" if v }.join.html_safe
  end

  def provider_span name
    name = name.to_s
    content_tag :span, :class => ['provider',name] do
      content_tag(:abbr, name[0]) << ' ' << name.capitalize
    end
  end
end
