# encoding: utf-8
class Api::APIController < ActionController::Metal
  # Bare metal rails controllers: http://newaperio.com/blog/19-fast-json-api-controllers-in-rails
  include AbstractController::Callbacks # before_filter
  include ActionController::Rendering
  include ActionController::Renderers::All
  include ActionController::MimeResponds

  # https://newrelic.com/docs/ruby/adding-instrumentation-to-actioncontroller-metal
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  before_filter :map_method, :limit_count

  DEFAULT_COUNT = 20
  MAX_COUNT = 200

  private

  def map_method
    # for JSONP requests
    map = {
      'index#POST'  => 'create',
      'show#PUT'    => 'update',
      'show#DELETE' => 'destroy'
    }
    if !params[:_method].blank?
      key = "#{action_name}##{params[:_method].upcase}"
      send map[key] if !map[key].blank? and respond_to? map[key]
    end
  end

  def limit_count
    if params[:count].blank?
      params[:count] = DEFAULT_COUNT
    else
      params[:count] = params[:count].to_i
      if params[:count] > MAX_COUNT
        params[:count] = MAX_COUNT
      end
    end
  end

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
