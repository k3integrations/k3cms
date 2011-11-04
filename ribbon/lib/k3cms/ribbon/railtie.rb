require "k3cms_ribbon"
require "rails"
require 'facets/kernel/__dir__'
require 'facets/pathname'
require 'cells'

module K3cms
  module Ribbon
    class Railtie < Rails::Engine

      config.before_initialize do
        # Work around the fact that the line:
        #   Bundler.require(:default, Rails.env) if defined?(Bundler)
        # in config/application.rb only does a 'require' for the gems explicitly listed in the app's Gemfile -- not for the gems *they* might depend on.
        require 'haml'
      end

      config.action_view.javascript_expansions[:k3cms_editing].concat [
        'jquery.tools.min.js',
        'jquery.timeago.js',
      ]
      config.action_view.javascript_expansions[:k3cms].concat [ 'k3cms/ribbon.js' ]
      config.action_view.stylesheet_expansions[:k3cms].concat [ 'k3cms/ribbon.css' ]

      initializer 'k3cms.ribbon.cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3cms.ribbon.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          include K3cms::Ribbon::ControllerMethods
          before_filter :set_edit_mode
        end
        Cell::Base.class_eval do
          include K3cms::Ribbon::ControllerMethods
        end
      end

      initializer 'k3cms.ribbon.helpers' do
        config.after_initialize do
          # Prevent "undefined method `inline_editor_object_class' for #<#<Class:0x00000005326590>:0x000000053200a0>" in ribbon/app/cells/k3cms/ribbon/context_ribbon_js.html.haml, etc.
          helpers = proc {
            helper K3cms::Ribbon::RibbonHelper
          }
          ActiveSupport.on_load(:action_controller, &helpers)
          Cell::Rails.class_eval(                   &helpers)

          # Prevent "undefined method `k3cms_ribbon_add_drawer' for #<#<Class:0x000000045112c0>:0x000000045023d8>" in pages/app/views/k3cms/pages/init.html.haml, etc.
          ActiveSupport.on_load(:action_view) do
            include K3cms::Ribbon::RibbonHelper
          end
        end
      end

      initializer 'k3cms.pages.hooks', :before => 'k3cms.core.hook_listeners' do |app|
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
