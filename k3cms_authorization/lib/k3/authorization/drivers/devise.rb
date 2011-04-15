module K3
  module Authorization
    module Drivers
      module Devise
        extend ActiveSupport::Concern

        private

        # Devise specific
        def k3_user
          current_user || @k3_guest_user ||= K3::Authorization::GuestUser.new
        end

        def k3_authorization_required
          if !user_signed_in?
            authenticate_user!
          else
            k3_failed_authorization
          end
        end

        def after_sign_in_path_for(resource)
          k3_successful_signin
        end

        def after_sign_out_path_for(resource)
          k3_successful_signout
        end

        public

        included do
          helper_method :k3_user, :k3_authorization_required
        end

      end
    end
  end
end
