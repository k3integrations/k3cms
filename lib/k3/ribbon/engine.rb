require "k3_ribbon"
require "rails"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module Ribbon

    class Engine < Rails::Engine
      config.action_view.javascript_expansions[:k3].concat [
        'http://cdn.jquerytools.org/1.2.5/all/jquery.tools.min.js',
        'k3/ribbon.js',
      ]

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
