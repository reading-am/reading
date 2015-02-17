module Api::V1
  module OauthAccessTokens
    def self.index(params = {})
      Doorkeeper::AccessToken.limit(params[:limit])
        .offset(params[:offset])
        .order('created_at DESC')
    end
  end
end
