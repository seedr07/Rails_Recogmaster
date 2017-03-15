module Api
  module V2
    module Entities
      class Base < Grape::Entity
        include Rails.application.routes.url_helpers
        include ActionDispatch::Routing::UrlFor
        include GrapeRouteHelpers::NamedRouteMatcher
        include ApplicationHelper # used for user_path/user_url customization

        expose :type
        expose :id
        expose :web_url, if: lambda{ |entity, options| self.id.present? }
        expose :api_url, if: lambda{ |entity, options| self.id.present? }

        def current_user
          self.options[:current_user]
        end

        def type
          self.object.class.to_s
        end

        def id
          self.object.recognize_hashid
        end

        def web_url
          polymorphic_url(self.object, web_url_opts)
        end

        def web_url_opts
          { host: Recognize::Application.config.host, protocol: "https" }
        end

        # v2_recognition_path
        # v2_users_path
        # v2_users_show_path
        def api_url
          # For now, there is no good way to do this polymorphically like the web url above
          # So, have to roll it myself based on resourceful convention
          resource = self.object.class.table_name
          opts = {}
          opts[:id] = self.object.recognize_hashid
          path = send("v2_#{resource}_path", opts)
          "https://#{Recognize::Application.config.host}/api#{path}"
        end
      end
    end
  end
end