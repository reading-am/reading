module Api::V1
  module Pages

    def self.index params={}
      if params[:user_id]
        user = User.find(params[:user_id])
        if params[:tag]
          pages = Page.with_tag_from_user(params[:tag], user)
        else
          pages = user.pages
        end
      else
        pages = Page.all
      end

      if params[:tag] && !params[:user_id]
        pages = pages.with_tag(params[:tag])
      end

      if params[:domain_id]
        # list a page's posts
        # pages/1/posts
        pages = pages.where(domain_id: params[:domain_id])
      end

      if params[:since_id]
        pages = pages.where("id > ?", params[:since_id])
      end

      if params[:max_id]
        pages = pages.where("id <= ?", params[:max_id])
      end

      if params[:medium] && params[:medium] != "all"
        pages = pages.where(medium: params[:medium])
      end

      pages = pages.limit(params[:limit])
              .offset(params[:offset])
    end
  end
end
