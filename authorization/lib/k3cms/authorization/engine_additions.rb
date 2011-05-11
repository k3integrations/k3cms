require 'rails/engine'

module Rails
  Engine.class_eval do
    class << self
      def authorization
        @authorization ||= K3cms::Authorization::AuthorizationSet.new
      end
    end
  end
end
