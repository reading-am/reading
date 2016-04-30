module Api::V1
  module Tags
    
    def self.index(params = {})
      if params[:user_id]
        tags = Tag.where(user_id: params[:user_id])
      elsif params[:page_id]
        tags = Tag.where(page_id: params[:page_id])
      else
        tags = Tag.all
      end

      tags = tags
             .limit(params[:limit])
             .offset(params[:offset])
    end
  end
end
