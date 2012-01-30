module UsersHelper
  def bookmarklet_url user
    "javascript:(function(){window.reading={token:'#{user.token}',platform:'bookmarklet',version:'#{BOOKMARKLET_VERSION}'};var head=document.getElementsByTagName('head')[0],script=document.createElement('script');script.src='//#{DOMAIN}/assets/bookmarklet/loader.js';head.appendChild(script);})()"
  end
end
