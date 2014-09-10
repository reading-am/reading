module Api::Posts

  def self.index params={}
    if params[:user_id]
      if params[:type] == "list"
        posts = Post.from_users_followed_by_including(params[:user_id])
      elsif params[:type] == "following"
        posts = Post.from_users_followed_by(params[:user_id])
      else
        # list a user's posts
        # users/1/posts
        posts = Post.where(user_id: params[:user_id])
      end
    elsif params[:page_id]
      # list a page's posts
      # pages/1/posts
      posts = Post.where(page_id: params[:page_id])
    else
      # list all posts
      # posts
      posts = Post.all
    end

    if params[:since_id]
      posts = posts.where("id > ?", params[:since_id])
    end

    if params[:max_id]
      posts = posts.where("id <= ?", params[:max_id])
    end

    posts = posts.limit(params[:limit])
                   .offset(params[:offset])

    if params[:medium] && params[:medium] != "all"
      ids = posts.joins(:page)
                  .where(pages: {medium: params[:medium]})
                  .order("posts.created_at DESC")
                  .pluck(:id)

      posts = Post.where(id: ids)
    end

    if params[:page_ids]
      posts = posts.where(page_id: params[:page_ids])
    end

    posts = posts.includes(:user, :page, {referrer_post: :user})
                   .order("created_at DESC")
  end

end
