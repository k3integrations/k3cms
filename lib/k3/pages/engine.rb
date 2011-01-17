require "rails"
require "k3_pages"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module Pages

    class Engine < Rails::Engine
      config.action_view.javascript_expansions[:k3] ||= []
      config.action_view.javascript_expansions[:k3].concat [
        'k3/pages.js',
      ]

      initializer 'k3.pages.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3.pages.add_middleware' do |app|
        app.middleware.use K3::Pages::CustomRouting
      end

      config.to_prepare do |app|
        require Pathname[__DIR__] + '../../../app/models/user.rb'
      end

    end

  end
end
