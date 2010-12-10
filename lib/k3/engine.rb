require "k3_core"
require "rails"

module K3
  class Engine < Rails::Engine
    puts "#{self}"

    config.action_view.javascript_expansions.merge! :k3 => []
  end
end
