require 'grape-swagger'
require 'api/v2/helpers/header_helpers'
module Api
  module V2
    class Base < Grape::API
      extend Api::V2::Documentation
      extend Api::V2::XAuthEmail
      extend Api::V2::Authorization

      mount Api::V2::Endpoints::Auth
      mount Api::V2::Endpoints::Recognitions
      mount Api::V2::Endpoints::Users
      mount Api::V2::Endpoints::Badges

      before do
        token = headers["Authorization"].match(/^Bearer\s(.*)/)[1] rescue nil
        if token.present? && access_token = Doorkeeper::AccessToken.find_by_token(token)
          ensure_email_auth_headers_on_swagger_route if access_token.resource_owner_id.blank?
        end
      end

      after do
        ensure_no_email_auth_headers_on_swagger_route
      end

      markdown_adapter = GrapeSwagger::Markdown::RedcarpetAdapter.new(render_options: { highlighter: :rouge }, fenced_code_blocks: true)
      add_swagger_documentation api_version: 'v2',
                                    info: {description: core_description},
                                    base_path: "/api/v2",
                                    hide_format: true,
                                    mount_path: 'spec',
                                    hide_module_from_path: true,
                                    hide_documentation_path: true,
                                    format: :json,
                                    markdown: markdown_adapter,#GrapeSwagger::Markdown::KramdownAdapter,
                                    # authorizations: {
                                    #   "Authorization" => {
                                    #     type: "oauth2"
                                    #   }
                                    # }
                                    authorizations: {
                                      :oauth2 => {
                                        type: "oauth2", 
                                        # grantTypes: {
                                        #   "implicit" => {
                                        #     loginEndpoint: {url: ""},
                                        #     token_name: "access_token"
                                        #   },
                                        #   "authorization_code" => {
                                        #     "tokenRequestEndpoint" => {url: 'tre.url'},
                                        #     "tokenEndpoint" => {url: "te.url"}
                                        #   }
                                        # },
                                        scopes: [{"scope" => "profile"}]
                                      }
                                    }

    end
  end
end