# encoding: utf-8
module ApplicationHelper
  def og_tags hash={}
    og = {
      :type   => "website",
      :title  => "✌ Reading",
      :description => "Share what you're reading. Not what you like. Not what you find interesting. Just what you're reading.",
      :image  => "apple-touch-icon.png"
    }
    og = og.merge(hash)
    og.collect {|k,v| "<meta property=\"og:#{h(k)}\" content=\"#{h(v)}\" />\n" if v }.join.html_safe
  end

  def provider_span input
    if input.class == Authorization
      provider = input.provider
      text = content_tag(:span, input.display_name, :class => 'account')
    else
      provider = input
      text = input.to_s.capitalize
    end
    content_tag :span, :class => ['provider', provider] do
      case provider.to_s
      when 'twitter', 'facebook'
        output = content_tag :span, provider[0], :class => 'glyph icon'
      when 'tumblr'
        output = content_tag :span, 'k', :class => 'glyph icon'
      when '37signals'
        output = content_tag :span, '✣', :class => 'icon'
      when 'instapaper'
        output = content_tag :span, 'I', :class => 'icon'
      when 'readability'
        output = content_tag :span, '♣', :class => 'icon'
      end
      output << ' ' << text
    end
  end

  def rss_path token = false
    path = request.path.split('/page')[0]
    "#{path + (path[-params[:type].length-1..-1] != "/#{params[:type]}" ? "/#{params[:type]}" : '')}.rss#{token ? "?t=#{token}" : ""}"
  end
end
