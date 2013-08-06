# encoding: utf-8
class Api::UsersController < Api::APIController

  def index
    respond_to do |format|
      format.json do
        render_json users: Api::Users.index(params).collect { |user| user.simple_obj }
      end
    end
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
      respond_to do |format|
        format.json { render_json user: @user.simple_obj }
      end
    else
      show_404
    end
  end
  add_transaction_tracer :show

  def expats
    params[:user_id] = params[:id]
    respond_to do |format|
      format.json { render_json users: Api::Users.expats(params).collect{ |u| u.simple_obj } }
    end
  end
  add_transaction_tracer :expats

  def recommended
    params[:user_id] = current_user.id
    respond_to do |format|
      format.json { render_json users: Api::Users.recommended(params).collect{ |u| u.simple_obj } }
    end
  end
  add_transaction_tracer :recommended

  def search
    respond_to do |format|
      format.json { render_json users: Api::Users.search(params).collect{ |u| u.simple_obj } }
    end
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
