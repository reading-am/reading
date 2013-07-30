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
      format.json { render_json :users => @users.collect { |user| user.simple_obj } }
    end
  end
  add_transaction_tracer :index

  def create

  end
  add_transaction_tracer :create

  def destroy

  end
  add_transaction_tracer :destroy

end
