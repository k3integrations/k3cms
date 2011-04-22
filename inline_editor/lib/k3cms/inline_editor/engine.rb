require "k3cms_inline_editor"
require "rails"
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module InlineEditor

    class Engine < Rails::Engine
      config.before_initialize do
        # Anything in the .gemspec that needs to be *required* should be required here.
        # This is a workaround for the fact that this line:
        #   Bundler.require(:default, Rails.env) if defined?(Bundler)
        # in config/application.rb only does a 'require' for the gems explicitly listed in the *app*'s Gemfile -- not for the gems *they* might depend on (which are listed in a .gemspec file, not a Gemfile).
        require 'best_in_place'
      end
      
      config.action_view.javascript_expansions[:k3].concat [
        'jquery.purr.js',
        'best_in_place.js',
        'css_browser_selector.js',
        'inline_editor.js',
        'k3cms/inline_editor.js',
      ]
      config.action_view.stylesheet_expansions[:k3].concat [
        'k3cms/inline_editor/jquery.purr.css',
        'k3cms/inline_editor.css',
      ]

      initializer 'k3.inline_editor.cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end

      initializer 'k3.inline_editor.hooks', :before => 'k3.core.hook_listeners' do |app|
        class K3cms::InlineEditor::Hooks < K3cms::ThemeSupport::HookListener
          insert_after :top_of_page do
            # TODO: should be able to call render_cell or other helpers directly from this context
            %{<%= render_cell 'k3cms/inline_editor', :init_edit_mode %>}
          end
        end
      end
    end

  end
end
