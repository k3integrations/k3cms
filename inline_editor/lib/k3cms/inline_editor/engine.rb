require "k3cms_inline_editor"
require "rails"
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module InlineEditor

    class Engine < Rails::Engine
      #puts "#{self}"

      #puts "config.action_view.javascript_expansions=#{config.action_view.javascript_expansions.inspect}"
      config.action_view.javascript_expansions[:k3].concat [
        'jquery.purr.js',
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
