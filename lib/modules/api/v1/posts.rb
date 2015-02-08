module Api::V1
  module Posts

    YN_MAP = { 'yeps'    => true,
               'nopes'   => false,
               'neutral' => nil }

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
      elsif params[:domain_id]
        posts = Post.from_domain(params[:domain_id])
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

      if params[:yn] && params[:yn] != 'any'
        posts = posts.where(yn: YN_MAP[params[:yn]])
      end

      if params[:medium] && params[:medium] != "all"
        posts = posts.where(pages: {medium: params[:medium]})
      end

      if params[:page_ids]
        posts = posts.where(page_id: params[:page_ids])
      end

      posts = posts.includes(:user, :page, {referrer_post: :user})
              .limit(params[:limit])
              .offset(params[:offset])
              .order("posts.created_at DESC")
    end
  end
end
