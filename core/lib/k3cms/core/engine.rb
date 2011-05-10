require 'singleton'
require "k3cms_core"
require "rails"
require 'k3cms/theme_support'

module K3cms
  module Core
    class Engine < Rails::Engine
      puts self

      config.action_view.javascript_expansions.merge! :k3cms_viewing => []
      config.action_view.javascript_expansions.merge! :k3cms_editing => []
      config.action_view.stylesheet_expansions.merge! :k3cms => []

      # A placeholder that other gems can hook into before or after
      initializer 'k3cms.core' do
        #puts 'k3cms.core'
      end

      initializer 'k3cms.core.action_view' do
        ActiveSupport.on_load(:action_view) do
          include K3cms::Core::CoreHelper
          include K3cms::Core::HookHelper
        end
      end

      initializer 'k3cms.pages.hooks', :before => 'k3cms.core.hook_listeners' do |app|
        class K3cms::Core::Hooks < K3cms::ThemeSupport::HookListener
          insert_after :head, :file => 'k3cms/head.html.erb'
        end
      end

      initializer 'k3cms.core.hook_listeners' do
        puts "K3cms::ThemeSupport::HookListener.subclasses=#{K3cms::ThemeSupport::HookListener.subclasses.inspect}"
        K3cms::ThemeSupport::HookListener.subclasses.each do |hook_class|
          K3cms::ThemeSupport::Hook.add_listener(hook_class)
        end
      end

      # A placeholder that other gems can hook into before or after
      initializer 'k3cms.core.require_decorators' do
        #puts 'k3cms.core.require_decorators'
      end

    end
  end
end
