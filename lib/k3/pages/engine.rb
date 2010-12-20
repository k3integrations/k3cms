require "k3_pages"
require "rails"
require 'facets'
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module Pages

    class Engine < Rails::Engine
      config.action_view.javascript_expansions[:k3].concat [
        'k3/pages.js',
      ]

      initializer 'k3.pages.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3.pages.add_middleware' do |app|
        app.middleware.use K3::Pages::CustomRouting
      end
    end

  end
end
