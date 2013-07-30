# encoding: utf-8
class Api::RelationshipsController < Api::APIController

  def index
    @user = User.find(params[:user_id])
    @users = @user.send(params[:type])

    if params[:user_ids]
      @users = @users.where(id: params[:user_ids])
    end

    @users = @users.limit(params[:limit])
                   .offset(params[:offset])
                   .order("created_at DESC")

    respond_to do |format|
      format.json { render_json users: @users.collect { |user| user.simple_obj } }
    end
  end
  add_transaction_tracer :index

  def create
    show_400 and return if params[:user_id].to_i != current_user.id

    @user = User.find(params[:user_ids])
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
