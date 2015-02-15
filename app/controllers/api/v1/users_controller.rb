# encoding: utf-8
module Api::V1
  class UsersController < ApiController

    def me
      render :show, locals: { user: current_user }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :me
    add_transaction_tracer :me

    def index
      render locals: { users: Users.index(params) }
    end
    add_transaction_tracer :index

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
    add_transaction_tracer :show

    def expats
      params[:user_id] = params[:id]
      render :index, { users: Users.expats(params) }
    end
    add_transaction_tracer :expats

    def recommended
      params[:user_id] = current_user.id
      render :index, { users: Users.recommended(params) }
    end
    add_transaction_tracer :recommended

    def search
      render :index, { users: Users.search(params) }
    end
    add_transaction_tracer :search

    def count
      if current_user.roles? :admin
        respond_to do |format|
          format.json { render_json total_users: User.count }
        end
      else
        show_404
      end
    end
    add_transaction_tracer :count
  end
end
