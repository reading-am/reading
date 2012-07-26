# encoding: utf-8
module ApplicationHelper
  include Twitter::Autolink

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
      when 'tssignals'
        output = content_tag :span, '✣', :class => 'icon'
      when 'instapaper'
        output = content_tag :span, 'I', :class => 'icon'
      when 'readability'
        output = content_tag :span, '♣', :class => 'icon'
      else
        output = content_tag :span
      end
      output << ' ' << text
    end
  end

  def rss_path token = false
    path = request.path.split('/page')[0]
    "#{path + (path[-params[:type].length-1..-1] != "/#{params[:type]}" ? "/#{params[:type]}" : '')}.rss#{token ? "?t=#{token}" : ""}"
  end

  def extension_install browser, text=false
    text = "#{browser.to_s.capitalize} Extension" if text.blank?
    case browser.to_s
      when 'chrome'
        link = 'https://chrome.google.com/webstore/detail/npjdbbeldblbjenemjdeplmlaieifjhk'
      when 'safari'
        link = 'http://reading-production.s3.amazonaws.com/extensions/reading.safariextz'
      when 'firefox'
        link = 'http://reading-production.s3.amazonaws.com/extensions/reading.xpi'
    end
    link_to text, link, :class => "btn #{browser}-install"
  end
end
