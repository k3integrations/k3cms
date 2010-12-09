require "k3_ribbon"
require "rails"
require 'facets'
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module Ribbon

    class Engine < Rails::Engine
      initializer 'k3.ribbon.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      config.to_prepare do
        ::ApplicationController.send :include, K3::Ribbon::ControllerMethods
        class ::ApplicationController
          before_filter :set_edit_mode
        end
      end
    end

  end
end
