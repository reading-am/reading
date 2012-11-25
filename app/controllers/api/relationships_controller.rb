# encoding: utf-8
class Api::RelationshipsController < Api::APIController

  def show
    @user = User.find_by_username(params[:username])
    puts @user.to_json
  end

end
