module UsersHelper
  def bookmarklet_url user
    "javascript:(function(){window.reading={token:'#{user.token}',platform:'bookmarklet',version:'#{BOOKMARKLET_VERSION}'};var head=document.getElementsByTagName('head')[0],script=document.createElement('script');script.src='#{Rails.env == 'production' ? 'https' : 'http'}://#{DOMAIN}/assets/bookmarklet/loader.js';head.appendChild(script);})()"
  end

  def mustache_helpers
    data = super
    data[:bookmarklet_url] = current_user ? bookmarklet_url(current_user) : ''
    data
  end
end
