module Api::V1
  module Domains
    def self.index(params = {})
      Domain.limit(params[:limit])
        .offset(params[:offset])
        .order('created_at DESC')
    end
  end
end
