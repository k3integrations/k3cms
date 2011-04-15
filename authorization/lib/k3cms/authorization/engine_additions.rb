module Rails
  class Engine
    class << self
      def authorization
        @authorization ||= K3cms::Authorization::AuthorizationSet.new
      end
    end
  end
end
