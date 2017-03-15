module Api
  module V2
    module Helpers
      module HeaderHelpers
        def ensure_email_auth_headers_on_swagger_route
          routes = Api::V2::Base.combined_namespace_routes[self.params.name]
          if routes.present?
            routes.each do |r| 
              route_options = r.instance_variable_get("@options")
              # If route has not specified, default to setting the header(this is only run if token does not have resource_owner_id set)
              # If route has specified required, use that setting
              # Can also specify that the header is optional
              if !route_options[:settings].has_key?(:x_auth_email) || route_options[:settings][:x_auth_email][:required] || route_options[:settings][:x_auth_email][:optional]
                route_options[:headers] ||= {}
                route_options[:headers]["X-Auth-Email"] ||= { description: 'Email of user to act as'}
                route_options[:headers]["X-Auth-Network"] ||= { description: 'Network of acting user'}
              end
            end
          end  
        end

        # FIXME: dry me up
        def ensure_no_email_auth_headers_on_swagger_route
          routes = Api::V2::Base.combined_namespace_routes[self.params.name]
          if routes.present?
            routes.each do |r| 
              route_options = r.instance_variable_get("@options")
              route_options[:headers] ||= {}
              route_options[:headers].delete("X-Auth-Email")
              route_options[:headers].delete("X-Auth-Network")              
            end
          end  
        end
      end
    end
  end
end
Grape::Endpoint.send(:include, Api::V2::Helpers::HeaderHelpers)      