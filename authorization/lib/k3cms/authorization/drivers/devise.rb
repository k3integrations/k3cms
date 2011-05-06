module K3cms
  module Authorization
    module Drivers
      module Devise
        extend ActiveSupport::Concern

        # Devise specific
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

        public

        included do
          helper_method :k3cms_user, :k3cms_authorization_required
        end

      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include K3cms::Authorization::Drivers::Devise
  include K3cms::Authorization::GeneralControllerMethods

  class Cell::Rails
    # Too bad delegate :current_ability doesn't work...
    delegate :k3cms_user, :to => :parent_controller
  end
  #Cell::Base.send :include, Devise::Controllers::Helpers
  #Cell::Base.send :include, K3cms::Authorization::Drivers::Devise
  #Cell::Base.send :include, K3cms::Authorization::GeneralControllerMethods
end
