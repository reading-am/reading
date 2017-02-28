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
      when 'instapaper'
        output = content_tag :span, 'I', :class => 'icon'
      when 'readability'
        output = content_tag :span, '♣', :class => 'icon'
      when 'evernote'
        output = content_tag :span, 'E', :class => 'icon'
      when 'pocket'
        output = content_tag :span, '▾', :class => 'icon'
      when 'slack'
        output = content_tag :span, '#', :class => 'icon'
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
        link = "http://#{ENV['S3_BUCKET']}/extensions/reading.safariextz"
      when 'firefox'
        link = "http://#{ENV['S3_BUCKET']}/extensions/reading.xpi"
    end
    link_to text, link, :class => "btn #{browser}-install"
  end

  def requirejs
    # this namespace must mirror what's in requirejs.yml
    "#{['production','staging'].include?(Rails.env) ? 'r_require.' : ''}require"
  end

  def js_manifest
    # via: https://github.com/jwhitley/requirejs-rails/blob/60231146fa7ab38b858e231aa41ad6dc4fa46370/lib/requirejs/rails/engine.rb#L59
    rjs_digests = YAML.load(ERB.new(File.new(Rails.application.config.requirejs.manifest_path).read).result)
    Hash[rjs_digests.collect { |key, val| [key[0..-4], val[0..-4]] }].to_json.html_safe
  rescue
    '{}'.html_safe
  end

  def mustache_helpers
    data = {
      signed_in: signed_in?,
      rss_path:  params[:type] ? rss_path : false
    }

    # Sections
    ['following', 'followers', 'posts', 'list'].each do |v|
      data[:"viewing_#{v}"] = params[:type] == v
    end

    # Browser detection
    data[:browser_has_extension] = browser.chrome? || browser.safari? || browser.firefox?
    [:chrome, :safari, :firefox].each do |v|
      data[:"browser_#{v}"] = browser.send("#{v}?")
      data[:"extension_install_#{v}"] = extension_install(v)
    end

    data
  end
end
