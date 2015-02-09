# encoding: utf-8
module Api::V1
  class UsersController < ApiController

    def me
      @user = current_user
      render :show
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :me
    add_transaction_tracer :me

    def index
      @users = Users.index(params)
      render
    end
    add_transaction_tracer :index

    def show
      if params[:user_id]
        # check if a user is following or follows another user
        # users/1/followers/2
        # users/2/following/1
        @base_user = User.find(params[:user_id])
        @user = @base_user.send(params[:type]).where(id: params[:id]).first
      else
        # show user
        # users/1
        @user = User.find(params[:id])
      end

      if !@user.blank?
        render
      else
        show_404
      end
    end
    add_transaction_tracer :show

    def expats
      params[:user_id] = params[:id]
      @users = Users.expats(params)
      render :index
    end
    add_transaction_tracer :expats

    def recommended
      params[:user_id] = current_user.id
      @users = Users.recommended(params)
      render :index
    end
    add_transaction_tracer :recommended

    def search
      @users = Users.search(params)
      render :index
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
