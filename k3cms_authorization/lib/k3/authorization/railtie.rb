module K3
  module Authorization
    class Railtie < Rails::Railtie
      initializer "k3_authorization.load_authorization_files" do |app|
        K3::Authorization::AuthorizationSet.load app.railties.engines
      end
    end
  end
end
