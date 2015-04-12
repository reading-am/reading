# encoding: utf-8
module Api::V1
  class DomainsController < ApiController

    def index
      render locals: { domains: Domains.index(params) }
    end
    require_scope_for :index, :public
    add_transaction_tracer :index

    def show
      render locals: { domain: Domain.find(params[:id]) }
    end
    require_scope_for :show, :public
    add_transaction_tracer :show

    def stats
      render 'shared/stats', locals: { model: Domain }
    end
    require_scope_for :stats, :admin
    add_transaction_tracer :stats
  end
end
