# encoding: utf-8
class Api::RelationshipsController < Api::APIController

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

    # NOTE - we use request.POST here because :user_id is
    # also the name of the route param which takes precedence
    @user = User.find(request.POST[:user_id])
    current_user.follow!(@user)

    respond_to do |format|
      format.json { render_json user: @user.simple_obj }
    end
  end
  add_transaction_tracer :create

  def destroy
    show_400 and return if params[:user_id].to_i != current_user.id

    @user = User.find(params[:id])
    current_user.unfollow!(@user)

    respond_to do |format|
      format.json { render_json user: @user.simple_obj }
    end
  end
  add_transaction_tracer :destroy

end
