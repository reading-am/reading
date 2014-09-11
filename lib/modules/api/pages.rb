module Api::Pages

  def self.index params={}
    if params[:domain_id]
      # list a page's posts
      # pages/1/posts
      pages = Page.where(domain_id: params[:domain_id])
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
