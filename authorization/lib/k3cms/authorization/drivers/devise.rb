module K3cms
  module Authorization
    module Drivers
      module Devise
        extend ActiveSupport::Concern

        # This is to prevent the after_sign_in_path_for method in K3cms::Authorization::Drivers::Devise from overriding the version defined here.  That seems to
        # be happening when the devise gem is required *after* the k3cms_authorization gem, which would cause the K3cms::Authorization::Drivers::Devise module to
        # be included into Devise::SessionsController (or one of its ancestors) last, which means that its version is the one that gets used.
        #
        # By including ::Devise::Controllers::Helpers into this module, we trick Ruby into changing the ancestry for that class, so ancestors will now show:
        #   ...
        #   K3cms::Authorization::Drivers::Devise,
        #   Devise::Controllers::Helpers,
        #   ...
        # no matter whether devise or k3cms_authorization is required first.
        #
        include ::Devise::Controllers::Helpers

        included do
          helper_method :k3cms_user, :k3cms_authorization_required
        end

      public

        def k3cms_user
          current_user || @k3cms_guest_user ||= K3cms::Authorization::GuestUser.new
        end

      private

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

      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include K3cms::Authorization::Drivers::Devise

  #Cell::Base.send :include, Devise::Controllers::Helpers
  #Cell::Base.send :include, K3cms::Authorization::Drivers::Devise
end
