module Rails
  class Engine
    class << self
      def authorization
        @authorization ||= K3::Authorization::AuthorizationSet.new
      end
    end
  end
end
