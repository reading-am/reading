module UsersHelper
  def bookmarklet_url user
    "javascript:var%20reading={token:'#{user.token}'},head=document.getElementsByTagName('head')[0],script=document.createElement('script');script.src='http://#{DOMAIN}/assets/loader.js';head.appendChild(script);"
  end
end
