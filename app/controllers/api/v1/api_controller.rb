# encoding: utf-8
module Api::V1
  class ApiController < ActionController::Metal
    # Needed for > Rails 4.0; order matters
    include AbstractController::Rendering
    include ActionView::Rendering
    # Bare metal rails controllers: http://www.slideshare.net/artellectual/developing-api-with-rails-metal
    include ActionController::Helpers
    include ActionController::Redirecting
    include ActionController::Rendering
    include ActionController::Renderers::All
    include ActionController::ConditionalGet
    # need this for responding to different types .json .xml etc...
    include ActionController::MimeResponds
    include AbstractController::Callbacks
    include ActionController::Rescue # rescue_from
    # need this to build 'params'
    include ActionController::Instrumentation
    include ActionController::ParamsWrapper
    include ActionController::StrongParameters
    include Devise::Controllers::Helpers
    include Rails.application.routes.url_helpers
    # for Doorkeeper oauth provider
    # https://github.com/doorkeeper-gem/doorkeeper/blob/master/spec/dummy/app/controllers/metal_controller.rb
    include ActionController::Head
    include Doorkeeper::Rails::Helpers

    # Concerns
    include DefaultParams

    # Add a search path for our views
    append_view_path File.join(Rails.root, 'app', 'views')
    append_view_path File.join(Rails.root, 'app', 'views', self.name.deconstantize.underscore)

    wrap_parameters format: [:json]
    before_action { request.format = 'json' }
    before_action :map_method,
                  :block_suspended,
                  :add_current_user_id

    rescue_from ActiveRecord::RecordNotFound, with: :show_404
    rescue_from ActionController::ParameterMissing, with: :show_400

    DEVISE_SCOPES = [:public, :write]

    def current_user
      return @current_user if @current_user

      if doorkeeper_token
        @current_user = User.find(doorkeeper_token.resource_owner_id)
      elsif params[:token]
        @current_user = User.find_by_token(params[:token])
      else
        @current_user = super
      end
    end

    private

    def add_current_user_id
      return unless params[:add_current_user_id] && current_user
      params[:user_id] ||= current_user.id
    end

    def map_method
      # for JSONP requests
      map = {
        'index#POST'  => 'create',
        'show#PATCH'  => 'update',
        'show#DELETE' => 'destroy'
      }
      if !params[:_method].blank?
        key = "#{action_name}##{params[:_method].upcase}"
        send map[key] if !map[key].blank? and respond_to? map[key]
      end
    end

    def show_400
      respond_to do |format|
        format.json { render_json 400 }
        format.any { head :bad_request }
      end
    end

    def show_404
      respond_to do |format|
        format.json { render_json 404 }
        format.any { head :not_found }
      end
    end

    def block_suspended
     head :forbidden if current_user.try(:suspended?)
    end

    def devise_session?
      # if there's no doorkeeper token but a current user is present,
      # that current user came through Devise
      !doorkeeper_token && current_user.present?
    end

    def authorize!(*scopes)
      if devise_session?
        head :forbidden unless scopes.all? { |s| DEVISE_SCOPES.include?(s.to_sym) }
      else
        doorkeeper_authorize!(*scopes)
      end
    end

    def self.require_scope_for(method, scope)
      before_action -> { authorize! scope }, only: method
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
          meta: {
            status: status,
            msg: Rack::Utils::HTTP_STATUS_CODES[status]
          },
          response: payload
        }
        status = :ok
      end

      render json: json, callback: callback, status: status
    end
  end
end
