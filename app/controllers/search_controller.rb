class SearchController < ApplicationController
  def index
    search = Post.search do
      fulltext params[:q] do
        boost(3.0) { with(:yn, true) }
        boost_fields :title => 2.0
      end
      with(:user_id, current_user.id)
      paginate :page => params[:page], :per_page => 100
    end
    @posts = search.results

    if search.total == 0
      search = Page.search do
        fulltext params[:q]
        paginate :page => params[:page], :per_page => 100
      end
      @pages = search.results
    end
  end
end
