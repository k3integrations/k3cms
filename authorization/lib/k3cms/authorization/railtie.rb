module K3cms
  module Authorization
    class Railtie < Rails::Railtie
      initializer "k3cms_authorization.load_authorization_files" do |app|
        K3cms::Authorization::AuthorizationSet.load app.railties.engines
      end
    end
  end
end
