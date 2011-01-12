module K3
  module Authorization
    module GeneralControllerMethods

      def self.included(base)
        base.helper_method :k3_logged_in?
      end

      def k3_logged_in?
        k3_user.k3_guest?
      end

      def k3_failed_authorization
        render :text => 'Failed Authorization'
      end

      def k3_successful_signin
        respond_to?(:root_url, true) ? root_url : '/'
      end

      def k3_successful_signout
        respond_to?(:root_url, true) ? root_url : '/'
      end

    end
  end
end
