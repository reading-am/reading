module UsersHelper
  def bookmarklet_url user
    "javascript:reading={};(function(){reading.token='#{user.token}';var otherlib=(typeof jQuery=='undefined'&&typeof $=='function');function getScript(url,success){var script=document.createElement('script');script.src=url;var head=document.getElementsByTagName('head')[0],done=false;script.onload=script.onreadystatechange=function(){if(!done&&(!this.readyState||this.readyState=='loaded'||this.readyState=='complete')){done=true;success();script.onload=script.onreadystatechange=null;head.removeChild(script);}};head.appendChild(script);}getScript('http://code.jquery.com/jquery-latest.min.js',function(){if(typeof jQuery=='undefined'){alert('There was an error loading Reading');}else{jQuery.getScript('http://#{DOMAIN}/javascripts/reading.js');}});})();"
  end
end
