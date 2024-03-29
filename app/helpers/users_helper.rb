module UsersHelper
  def bookmarklet_url user
    "javascript:(function(){window.reading={token:'#{user.token}',platform:'bookmarklet',version:'#{BOOKMARKLET_VERSION}'};var head=document.getElementsByTagName('head')[0],script=document.createElement('script');script.src='#{ROOT_URL}/assets/bookmarklet/loader.js';head.appendChild(script);})()"
  end

  def mustache_helpers
    data = super

    data[:bookmarklet_url] = current_user ? bookmarklet_url(current_user) : ''

    if @user
      user = render_api partial: 'users/user', user: @user
      has_avatar = @user != current_user or !@user.avatar.size.nil?
      user.merge!({'show_blank_slate' =>   ((params[:type] == 'posts' && @user.posts.size == 0) ||
                                            (params[:type] == 'list' && @user.following.size == 0)),
                   'is_current_user' =>    @user == current_user,
                   'avatar_link_url' =>    has_avatar ? @user.avatar_url : "/settings/info",
                   'avatar_link_target' => has_avatar ? "_blank" : false,
                   'you_or_name' =>        @user == current_user ? 'you' : @user.first_name,
                   'is_following' =>       signed_in? && current_user.following?(@user),
                   'has_followed' =>       @user.following.size > 0,
                   'has_link' =>           !@user.link.blank?,
                   'has_location' =>       !@user.location.blank?})
      data[:user] = user
    end

    data
  end
end
