module K3cms
  module Authorization
    module Drivers
      module Devise
        extend ActiveSupport::Concern

        private

        # Devise specific
        def k3cms_user
          current_user || @k3cms_guest_user ||= K3cms::Authorization::GuestUser.new
        end

        def k3cms_authorization_required(exception = nil)
          if !user_signed_in?
            authenticate_user!
          else
            k3cms_failed_authorization(exception)
          end
        end

        def k3cms_failed_authorization(exception)
          redirect_to '/users/sign_in', :alert => exception.message
        end

        def after_sign_in_path_for(resource)
          k3cms_successful_signin
        end

        def after_sign_out_path_for(resource)
          k3cms_successful_signout
        end

        public

        included do
          helper_method :k3cms_user, :k3cms_authorization_required
        end

      end
    end
  end
end
