require "rails"
require 'cells'
require "k3cms_pages"
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module Pages
    class Railtie < Rails::Engine

      config.before_initialize do
        # Anything in the .gemspec that needs to be *required* should be required here.
        # This is a workaround for the fact that this line:
        #   Bundler.require(:default, Rails.env) if defined?(Bundler)
        # in config/application.rb only does a 'require' for the gems explicitly listed in the *app*'s Gemfile -- not for the gems *they* might depend on (which are listed in a .gemspec file, not a Gemfile).
        require 'cancan'
      end

      config.action_view.javascript_expansions[:k3cms_editing].concat [
        'k3cms/pages.js',
      ]
      config.action_view.stylesheet_expansions[:k3cms].concat [
        'k3cms/pages.css',
      ]

      initializer 'k3cms.pages.cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3cms.pages.middleware' do |app|
        app.middleware.use K3cms::Pages::CustomRouting
      end

      initializer 'k3cms.pages.hooks', :before => 'k3cms.core.hook_listeners' do |app|
        class K3cms::Pages::Hooks < K3cms::ThemeSupport::HookListener
          insert_after :top_of_page, :file => 'k3cms/pages/init.html.haml'
        end
      end

      initializer 'k3cms.pages.require_decorators', :after => 'k3cms.core.require_decorators' do |app|
        #puts 'k3cms.pages.require_decorators'
        Dir.glob(config.root + "app/**/*_decorator*.rb") do |c|
          Rails.env.production? ? require(c) : load(c)
        end
      end

    end
  end
end
