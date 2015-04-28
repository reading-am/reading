# encoding: utf-8
module Mailman
  class DebugController < Api::V1::ApiController

    # For debugging Mailgun routes
    def echo_params
      render json: params['debug'].to_json
    end
  end
end
