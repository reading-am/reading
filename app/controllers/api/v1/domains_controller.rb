# encoding: utf-8
module Api::V1
  class DomainsController < ApiController

    add_transaction_tracer :index
    require_scope_for :index, :public
    def index
      render locals: { domains: Domains.index(params) }
    end

    add_transaction_tracer :show
    require_scope_for :show, :public
    def show
      render locals: { domain: Domain.find(params[:id]) }
    end

    add_transaction_tracer :count
    require_scope_for :count, :admin
    def count
      render_json total_comments: Domain.count
    end
  end
end
