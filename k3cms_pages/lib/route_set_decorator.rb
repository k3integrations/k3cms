require 'action_dispatch/routing/route_set'
#require 'rack/mount'
#require 'forwardable'
#require 'active_support/core_ext/object/to_query'
#require 'action_dispatch/routing/deprecated_mapper'

# Based on recognize_path from actionpack-3.0.4/lib/action_dispatch/routing/route_set.rb
module ActionDispatch
  module Routing
    class RouteSet #:nodoc:

      def recognize_route_from_path(path, environment = {})
        method = (environment[:method] || "GET").to_s.upcase
        path = Rack::Mount::Utils.normalize_path(path) unless path =~ %r{://}

        begin
          env = Rack::MockRequest.env_for(path, {:method => method})
        rescue URI::InvalidURIError => e
          raise ActionController::RoutingError, e.message
        end

        req = @request_class.new(env)
        @set.recognize(req) do |route, matches, params|
          params.each do |key, value|
            if value.is_a?(String)
              value = value.dup.force_encoding(Encoding::BINARY) if value.encoding_aware?
              params[key] = URI.unescape(value)
            end
          end

          dispatcher = route.app
          dispatcher = dispatcher.app while dispatcher.is_a?(Mapper::Constraints)
          return route
        end
      end

    end
  end
end
