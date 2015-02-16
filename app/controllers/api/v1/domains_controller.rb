# encoding: utf-8
module Api::V1
  class DomainsController < ApiController

    def index
      render locals: { domains: Domains.index(params) }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :index
    add_transaction_tracer :index

    def show
      render locals: { domain: Domain.find(params[:id]) }
    end
    add_transaction_tracer :show

    def count
      if current_user.roles? :admin
        respond_to do |format|
          format.json { render_json total_comments: Domain.count }
        end
      else
        show_404
      end
    end
    add_transaction_tracer :count
  end
end
