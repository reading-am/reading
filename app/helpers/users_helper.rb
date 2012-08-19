module UsersHelper
  def bookmarklet_url user
    "javascript:(function(){window.reading={token:'#{user.token}',platform:'bookmarklet',version:'#{BOOKMARKLET_VERSION}'};var head=document.getElementsByTagName('head')[0],script=document.createElement('script');script.src='#{Rails.env == 'production' ? 'https' : 'http'}://#{DOMAIN}/assets/bookmarklet/#{['production','staging'].include? Rails.env ? '' : 'dev_'}loader.js';head.appendChild(script);})()"
  end
end
