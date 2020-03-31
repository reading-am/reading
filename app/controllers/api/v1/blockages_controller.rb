# encoding: utf-8
module Api::V1
  class BlockagesController < ApiController

    private

    def blockage_params
      params.require(:model).permit(:blocker_id, :blocked_id)
    end

    public

    def index
      render 'users/index', locals: { users: Blockages.index(params) }
    end
    # only allow admins to see who is blocking someone
    before_action -> { authorize! params[:type] == 'blockers' ? :admin : :public }, only: :index
    
    def create
      show_400 && return if params[:user_id].to_i != current_user.id

      blocked = User.find(blockage_params[:blocked_id])
      current_user.unfollow!(blocked) rescue nil
      current_user.block!(blocked)

      render 'users/show', locals: { user: blocked }
    end
    require_scope_for :create, :write

    def destroy
      show_400 && return if params[:user_id].to_i != current_user.id

      blocked = User.find(params[:id])
      current_user.unblock!(blocked)

      render 'users/show', locals: { user: blocked }
    end
    require_scope_for :destroy, :write
  end
end
