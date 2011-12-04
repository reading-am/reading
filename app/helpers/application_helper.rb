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

  def provider_span input
    if input.class == Authorization
      provider = input.provider
      text = content_tag(:span, input.uid, :class => 'account')
    else
      provider = input
      text = input.to_s.capitalize
    end
    content_tag :span, :class => ['provider',provider] do
      case provider.to_s
      when 'twitter', 'facebook'
        output = content_tag(:abbr, provider[0])
      when '37signals'
        output = content_tag(:span, '✣')
      end
      output << ' ' << text
    end
  end

  def rss_path
    "#{request.path + (request.path[params[:type].length+1..-1] != "/#{params[:type]}" ? "/#{params[:type]}" : '')}.rss?t=#{current_user.token}"
  end
end
