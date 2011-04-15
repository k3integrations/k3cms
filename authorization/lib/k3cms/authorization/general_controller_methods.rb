module K3cms
  module Authorization
    module GeneralControllerMethods

      def self.included(base)
        base.helper_method :k3cms_logged_in?
      end

      def k3cms_logged_in?
        k3cms_user.k3cms_guest?
      end

      def k3cms_failed_authorization
        render :text => 'Failed Authorization'
      end

      def k3cms_successful_signin
        respond_to?(:root_url, true) ? root_url : '/'
      end

      def k3cms_successful_signout
        respond_to?(:root_url, true) ? root_url : '/'
      end

    end
  end
end
