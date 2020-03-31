# encoding: utf-8
module Api::V1
  class UsersController < ApiController

    # Override from api_controller so that :id will be set when missing
    def add_current_user_id
      return unless params[:add_current_user_id] && current_user
      params[:user_id] ||= current_user.id if params[:id].present?
      params[:id] ||= current_user.id
    end

    def index
      render locals: { users: Users.index(params) }
    end
    require_scope_for :index, :public
    
    def show
      if params[:user_id]
        # check if a user is following or follows another user
        # users/1/followers/2
        # users/2/following/1
        base_user = User.find(params[:user_id])
        user = base_user.send(params[:type]).where(id: params[:id]).first
      else
        # show user
        # users/1
        user = User.find(params[:id])
      end

      if !user.blank?
        render locals: { user: user }
      else
        show_404
      end
    end
    require_scope_for :show, :public

    def expats
      params[:user_id] = params[:id]
      render :index, locals: { users: Users.expats(params) }
    end
    require_scope_for :expats, :public

    def recommended
      params[:user_id] = current_user.id
      render :index, locals: { users: Users.recommended(params) }
    end
    require_scope_for :recommended, :public

    def search
      render :index, locals: { users: Users.search(params) }
    end
    require_scope_for :search, :public

    def count
      render_json total_users: User.count
    end
    require_scope_for :count, :admin

    private

    def user_params
      params.permit(:name)
    end
  end
end
