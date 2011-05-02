require "rails"
require 'cells'
require "k3cms_pages"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module Pages

    class Engine < Rails::Engine
      config.action_view.javascript_expansions[:k3] ||= []
      config.action_view.javascript_expansions[:k3].concat [
        'k3cms/pages.js',
      ]
      config.action_view.stylesheet_expansions[:k3].concat [
        'k3cms/pages.css',
      ]

      initializer 'k3.pages.cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3.pages.middleware' do |app|
        app.middleware.use K3cms::Pages::CustomRouting
      end

      initializer 'k3.pages.hooks', :before => 'k3.core.hook_listeners' do |app|
        class K3cms::Pages::Hooks < K3cms::ThemeSupport::HookListener
          insert_after :top_of_page, :file => 'k3cms/pages/init.html.haml'
        end
      end

      initializer 'k3.pages.require_decorators', :after => 'k3.core.require_decorators' do |app|
        #puts 'k3.pages.require_decorators'
        Dir.glob(config.root + "app/**/*_decorator*.rb") do |c|
          Rails.env.production? ? require(c) : load(c)
        end
      end

    end

  end
end
