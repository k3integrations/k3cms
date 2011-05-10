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
      initializer "k3cms.authorization.load_authorization_files", :before => 'k3cms.core.require_decorators' do |app|
        K3cms::Authorization::AuthorizationSet.load app.railties.engines
      end

      initializer 'k3cms.authorization.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          include K3cms::Authorization::GeneralControllerMethods
        end
        Cell::Base.class_eval do
          # Too bad delegate :current_ability doesn't seem to work...
          delegate :k3cms_user, :to => :parent_controller
          helper_method :k3cms_user
          #include  K3cms::Authorization::GeneralControllerMethods
        end
      end

      # If Devise is loaded, load some necessary Devise modules.
      initializer 'k3cms.authorization.devise' do
        if defined?(::Devise)
          require 'k3cms/authorization/drivers/devise'
        end
      end

    end
  end
end

