# encoding: utf-8
module Api::V1
  class BlockagesController < ApiController

    private

    def blockage_params
      params.require(:model).permit(:blocker_id, :blocked_id)
    end

    public

    add_transaction_tracer :index
    require_scope_for :index, :public
    def index
      render 'users/index', locals: { users: Blockages.index(params) }
    end

    add_transaction_tracer :create
    require_scope_for :create, :write
    def create
      show_400 && return if params[:user_id].to_i != current_user.id

      blocked = User.find(blockage_params[:blocked_id])
      current_user.unfollow!(blocked) rescue nil
      current_user.block!(blocked)

      render 'users/show', locals: { user: blocked }
    end

    add_transaction_tracer :destroy
    require_scope_for :destroy, :write
    def destroy
      show_400 && return if params[:user_id].to_i != current_user.id

      blocked = User.find(params[:id])
      current_user.unblock!(blocked)

      render 'users/show', locals: { user: blocked }
    end
  end
end
