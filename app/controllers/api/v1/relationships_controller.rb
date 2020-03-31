# encoding: utf-8
module Api::V1
  class RelationshipsController < ApiController

    def index
      render 'users/index', locals: { users: Relationships.index(params) }
    end
    require_scope_for :index, :public
    
    def create
      show_400 && return if params[:user_id].to_i != current_user.id

      followed = User.find(rel_params[:followed_id])
      current_user.follow!(followed)
      current_user.unblock!(followed) if current_user.blocking_count > 0 rescue nil

      render 'users/show', locals: { user: followed }
    end
    require_scope_for :create, :write

    def destroy
      show_400 and return if params[:user_id].to_i != current_user.id

      followed = User.find(params[:id])
      current_user.unfollow!(followed)

      render 'users/show', locals: { user: followed }
    end
    require_scope_for :destroy, :write

    private

    def rel_params
      params.require(:model).permit(:follower_id, :followed_id)
    end
  end
end
