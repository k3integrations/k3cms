require "k3cms_ribbon"
require "rails"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module Ribbon
    class Engine < Rails::Engine

      config.action_view.javascript_expansions[:k3] ||= []
      config.action_view.javascript_expansions[:k3].concat [
        'jquery.tools.min.js',
        'jquery.timeago.js',
        'k3cms/ribbon.js',
      ]
      config.action_view.stylesheet_expansions[:k3].concat [
        'k3cms/ribbon.css',
      ]

      initializer 'k3.ribbon.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      config.before_initialize do
        # Work around the fact that the line:
        #   Bundler.require(:default, Rails.env) if defined?(Bundler)
        # in config/application.rb only does a 'require' for the gems explicitly listed in the app's Gemfile -- not for the gems *they* might depend on.
        require 'haml'
        #require 'haml-rails'
      end

      initializer 'k3.ribbon.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          include K3cms::Ribbon::ControllerMethods
          before_filter :set_edit_mode
        end
      end

      initializer 'k3.ribbon.action_view' do
        ActiveSupport.on_load(:action_view) do
          include K3cms::Ribbon::RibbonHelper
        end
      end

    end
  end
end