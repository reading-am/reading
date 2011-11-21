class FootnotesController < ApplicationController
  layout "bare"

  def show
    render params['id']
  end
end
