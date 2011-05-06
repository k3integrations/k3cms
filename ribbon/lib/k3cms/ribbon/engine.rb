require "k3cms_ribbon"
require "rails"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'
require 'cells'

module K3cms
  module Ribbon
    class Engine < Rails::Engine

      config.before_initialize do
        # Work around the fact that the line:
        #   Bundler.require(:default, Rails.env) if defined?(Bundler)
        # in config/application.rb only does a 'require' for the gems explicitly listed in the app's Gemfile -- not for the gems *they* might depend on.
        require 'haml'
        #require 'haml-rails'
      end

      config.action_view.javascript_expansions[:k3] ||= []
      config.action_view.javascript_expansions[:k3].concat [
        'jquery.tools.min.js',
        'jquery.timeago.js',
        'k3cms/ribbon.js',
      ]
      config.action_view.stylesheet_expansions[:k3].concat [
        'k3cms/ribbon.css',
      ]

      initializer 'k3.ribbon.cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3.ribbon.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          include K3cms::Ribbon::ControllerMethods
          before_filter :set_edit_mode
        end
        Cell::Base.class_eval do
          include K3cms::Ribbon::ControllerMethods
        end
      end

      initializer 'k3.ribbon.action_view' do
        ActiveSupport.on_load(:action_view) do
          include K3cms::Ribbon::RibbonHelper
        end
      end

      initializer 'k3.pages.hooks', :before => 'k3.core.hook_listeners' do |app|
        class K3cms::Ribbon::Hooks < K3cms::ThemeSupport::HookListener
          insert_after :ribbon do
            # TODO: should be able to call render_cell or other helpers directly from this context
            %{
              <%
                @k3cms_ribbon_items   = k3cms_ribbon_items
                @k3cms_ribbon_drawers = k3cms_ribbon_drawers
              %>
              <%= k3cms_ribbon %>
            }
          end
        end
      end
    end
  end
end
