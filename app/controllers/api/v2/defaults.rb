module Api::V2::Defaults
  extend ActiveSupport::Concern
  included do
    # common Grape settings
    version 'v2', using: :path
    format :json
    content_type :json, 'application/json'

    use ::WineBouncer::OAuth2

    before do
      authorize!
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    helpers Api::V2::Helpers::SessionHelpers
    helpers Api::V2::Helpers::ParamsHelpers
    helpers Api::V2::Helpers::CoreHelpers
    # helpers Api::V2::Authorization::Helpers

    # global handler for simple not found case
    # rescue_from ActiveRecord::RecordNotFound do |e|
    #   error_response(message: e.message, status: 404)
    # end

    # global exception handler, used for error notifications
    rescue_from :all do |e|
      entity = Api::V2::Entities::ErrorResponse.factory(e) 
      json = entity.to_json
      status = entity.status
      # json = opts.to_json

      Rack::Response.new(json, status, {
        'Content-Type' => "application/json",
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => '*',
      }).finish
    end

  end
end