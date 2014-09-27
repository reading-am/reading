# encoding: utf-8
class Api::RelationshipsController < Api::APIController

  private

  def rel_params
    params.require(:model).permit(:follower_id, :followed_id)
  end

  public

  def index
    respond_to do |format|
      format.json do
        render_json users: Api::Relationships.index(params).collect { |user| user.simple_obj }
      end
    end
  end
  add_transaction_tracer :index

  def create
    show_400 and return if params[:user_id].to_i != current_user.id

    @followed = User.find(rel_params[:followed_id])
    current_user.follow!(@followed)

    respond_to do |format|
      format.json { render_json user: @followed.simple_obj }
    end
  end
  add_transaction_tracer :create

  def destroy
    show_400 and return if params[:user_id].to_i != current_user.id

    @followed = User.find(params[:id])
    current_user.unfollow!(@followed)

    respond_to do |format|
      format.json { render_json user: @followed.simple_obj }
    end
  end
  add_transaction_tracer :destroy

end
