module Api::V1
  module Blockages

    def self.index params={}
      user = User.find(params[:user_id])
      users = user.send(params[:type])

      if params[:user_ids]
        users = users.where(id: params[:user_ids])
      end

      users = users.limit(params[:limit])
              .offset(params[:offset])
              .order("created_at DESC")
    end

  end
end
