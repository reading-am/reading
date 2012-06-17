# encoding: utf-8
class Api::APIController < ApplicationController

  def show_404
    respond_to do |format|
      format.json { render_json 404 }
      format.any { head :not_found }
    end
  end

  def render_json payload = {}, status = :ok
    if payload.is_a? Integer or payload.is_a? Symbol
      status = payload
      payload = {}
    end

    status = Rack::Utils.status_code(status)
    callback = params[:callback]

    if callback.blank?
      json = payload
    else
      json = {
        :meta => {
          :status => status,
          :msg => Rack::Utils::HTTP_STATUS_CODES[status]
        },
        :response => payload
      }
      status = :ok
    end

    render :json => json, :callback => callback, :status => status
  end

end
