module Api::V1
  module Comments
    
    def self.index params={}
      if params[:user_id]
        comments = Comment.where(user_id: params[:user_id])
      elsif params[:page_id]
        comments = Comment.where(page_id: params[:page_id])
      else
        comments = Comment.all
      end

      if params[:since_id]
        comments = comments.where("id > ?", params[:since_id])
      end

      if params[:max_id]
        comments = comments.where("id <= ?", params[:max_id])
      end

      comments = comments.limit(params[:limit])
                 .offset(params[:offset])

      if params[:medium] && params[:medium] != "all"
        ids = comments.joins(:page)
              .where(pages: {medium: params[:medium]})
              .order("comments.created_at DESC")
              .pluck(:id)

        comments = Comment.where(id: ids)
      end

      if params[:page_ids]
        comments = comments.where(page_id: params[:page_ids])
      end

      comments = comments.includes([:user, :page])
                 .order("created_at DESC")
    end

  end
end
