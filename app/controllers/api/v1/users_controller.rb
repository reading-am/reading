# encoding: utf-8
module Api::V1
  class UsersController < ApiController

    add_transaction_tracer :me
    require_scope_for :me, :public
    def me
      render :show, locals: { user: current_user }
    end

    add_transaction_tracer :index
    require_scope_for :index, :public
    def index
      render locals: { users: Users.index(params) }
    end

    add_transaction_tracer :show
    require_scope_for :show, :public
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

    add_transaction_tracer :expats
    require_scope_for :expats, :public
    def expats
      params[:user_id] = params[:id]
      render :index, { users: Users.expats(params) }
    end

    add_transaction_tracer :recommended
    require_scope_for :recommended, :public
    def recommended
      params[:user_id] = current_user.id
      render :index, { users: Users.recommended(params) }
    end

    add_transaction_tracer :search
    require_scope_for :search, :public
    def search
      render :index, { users: Users.search(params) }
    end

    add_transaction_tracer :count
    require_scope_for :count, :admin
    def count
      render_json total_users: User.count
    end
  end
end
