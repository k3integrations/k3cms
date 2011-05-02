module K3cms
  module Authorization
    module GeneralControllerMethods

      def self.included(base)
        base.helper_method :k3cms_logged_in?
      end

      def k3cms_logged_in?
        k3cms_user.k3cms_guest?
      end

      def k3cms_failed_authorization_message(exception)
        if CanCan::AccessDenied === exception
          "#{exception.message} (#{exception.action} is not allowed for #{exception.subject})"
        else
          exception.message
        end
      end

      def k3cms_failed_authorization(exception)
        render :text => k3cms_failed_authorization_message(exception)
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
