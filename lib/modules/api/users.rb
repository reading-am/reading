module Api::Users

  def self.index params={}
    if params[:page_id]
      # list users who have visited a page
      # pages/1/users
      users = User.who_posted_to(params[:page_id])

      # this is disabled until we get more users on the site
      # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }
    end

    if params[:user_ids]
      users = users.where(id: params[:user_ids])
    end

    users = users.limit(params[:limit])
                 .offset(params[:offset])
                 .order("created_at DESC")
  end

  def self.recommended params={}
    if params[:user_id]
      following_ids = %(SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id)
      users = User.where("id NOT IN (#{following_ids}) AND id != :user_id", user_id: params[:user_id])
    else
      users = User.all
    end

    users = users.where("posts_count > ?", 300)
                 .order("followers_count DESC")
                 .limit(20)
  end

  def self.expats params={}
    users = []

    Authorization.where(user_id: params[:user_id]).each do |a|
      # TODO - this rescue is here because I still need to fix Facebook
      # token renewal. Once they expire, it will kill this without rescue
      users |= a.following rescue []
    end

    # don't include the user being queried on
    users.delete_if { |u| u.id == params[:user_id] }

    users
  end

  def self.search params={}
    search = User.search do fulltext params[:q] end
    search.results
  end
end
