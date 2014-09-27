# encoding: utf-8
class Api::BlockagesController < Api::APIController

  private

  def blockage_params
    params.require(:model).permit(:blocker_id, :blocked_id)
  end

  public

  def create
    show_400 and return if blockage_params[:blocker_id].to_i != current_user.id

    @blocked = User.find(blockage_params[:blocked_id])
    current_user.block!(@blocked)

    respond_to do |format|
      format.json { render_json user: @blocked.simple_obj }
    end
  end
  add_transaction_tracer :create

  def destroy
    show_400 and return if blockage_params[:blocker_id].to_i != current_user.id

    @blocked = User.find(blockage_params[:blocked_id])
    current_user.unfollow!(@blocked)

    respond_to do |format|
      format.json { render_json user: @blocked.simple_obj }
    end
  end
  add_transaction_tracer :destroy

end
