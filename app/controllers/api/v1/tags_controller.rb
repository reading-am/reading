# encoding: utf-8
module Api::V1
  class TagsController < ApiController

    def index
      tags = Tags.index(params)
      render locals: { tags: tags }
    end
    require_scope_for :index, :public
    add_transaction_tracer :index
  end
end
