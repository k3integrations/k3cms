require "k3_core"
require "rails"

module K3
  module Core
    class Engine < Rails::Engine
      #puts "#{self}"

      config.action_view.javascript_expansions.merge! :k3 => []
      config.action_view.stylesheet_expansions.merge! :k3 => []

      initializer 'k3.core.action_view' do
        ActiveSupport.on_load(:action_view) do
          include K3::Core::CoreHelper
        end
      end

    end
  end
end
