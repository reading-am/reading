# encoding: utf-8
module Api::V1
  class BlockagesController < ApiController

    private

    def blockage_params
      params.require(:model).permit(:blocker_id, :blocked_id)
    end

    public

    def index
      @users = Blockages.index(params)
      render
    end
    add_transaction_tracer :index

    def create
      show_400 && return if params[:user_id].to_i != current_user.id

      @blocked = User.find(blockage_params[:blocked_id])
      current_user.unfollow!(@blocked) rescue nil
      current_user.block!(@blocked)

      respond_to do |format|
        format.json { render_json user: @blocked.simple_obj }
      end
    end
    add_transaction_tracer :create

    def destroy
      show_400 && return if params[:user_id].to_i != current_user.id

      @blocked = User.find(params[:id])
      current_user.unblock!(@blocked)

      respond_to do |format|
        format.json { render_json user: @blocked.simple_obj }
      end
    end
    add_transaction_tracer :destroy
  end
end