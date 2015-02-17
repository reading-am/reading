module Api::V1
  module OauthApplications
    def self.index(params = {})
      Doorkeeper::Application.limit(params[:limit])
        .offset(params[:offset])
        .order('created_at DESC')
    end
  end
end
