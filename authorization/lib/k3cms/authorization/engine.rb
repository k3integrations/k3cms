require "k3cms_core"
require "rails"

module K3cms
  module Authorization
    class Engine < Rails::Engine
      puts self

      # This initializer must be loaded *before* all the require_decorators
      # initializers, because require_decorators causes User to be loaded, which
      # includes the RealUser module, which causes the permission sets to be loaded and
      # cached in a class variable. So if User gets loaded before all the
      # authorization.rb files have been loaded, the list of permissions will be empty
      # (the default) because none of the gems have added their permissions yet.
      initializer "k3cms.authorization.load_authorization_files", :before => 'k3.core.require_decorators' do |app|
        puts "k3cms.authorization.load_authorization_files"
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

