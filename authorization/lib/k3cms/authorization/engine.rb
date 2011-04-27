require "k3cms_core"
require "rails"

module K3cms
  module Authorization
    class Engine < Rails::Engine
      initializer "k3cms.authorization.load_authorization_files" do |app|
        K3cms::Authorization::AuthorizationSet.load app.railties.engines
      end

      # If *Devise* is loaded, load some necessary Devise modules.
      # TODO: can we move all of this into k3cms/authorization/drivers/devise.rb?
      initializer 'k3.authorization.devise' do
        ActiveSupport.on_load(:action_controller) do
          if defined?(::Devise)
            require 'k3cms/authorization/drivers/devise'
            include K3cms::Authorization::Drivers::Devise
            include K3cms::Authorization::GeneralControllerMethods

            Cell::Base.send :include, Devise::Controllers::Helpers
            Cell::Base.send :include, K3cms::Authorization::Drivers::Devise
            Cell::Base.send :include, K3cms::Authorization::GeneralControllerMethods
          end
        end
      end

    end
  end
end

