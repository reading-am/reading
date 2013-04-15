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
    og.collect {|k,v| "<meta property=\"og:#{h(k)}\" content=\"#{h(v)}\" />\n" if !v.blank? }.join.html_safe
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
      when 'email'
        output = content_tag :span, '@', :class => 'glyph icon'
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
      when 'evernote'
        output = content_tag :span, 'E', :class => 'icon'
      when 'kippt'
        output = content_tag :span, 'k', :class => 'icon'
      when 'pocket'
        output = content_tag :span, '▾', :class => 'icon'
      when 'flattr'
        output = content_tag :span, '⧓', :class => 'icon'
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
        link = "http://#{ENV['READING_S3_BUCKET']}/extensions/reading.safariextz"
      when 'firefox'
        link = "http://#{ENV['READING_S3_BUCKET']}/extensions/reading.xpi"
    end
    link_to text, link, :class => "btn #{browser}-install"
  end

  def requirejs
    # this namespace must mirror what's in requirejs.yml
    "#{['production','staging'].include?(Rails.env) ? 'r_require.' : ''}require"
  end

  def js_manifest
    manifest = {}
    yaml = YAML.load(File.new("#{Rails.root}/public/assets/rjs_manifest.yml")) rescue {}
    yaml.each {|key, val| manifest[key[0..-4]] = val[0..-4] }
    manifest.to_json.html_safe
  end
end
