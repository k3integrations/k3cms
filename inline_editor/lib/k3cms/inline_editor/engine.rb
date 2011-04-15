require "k3cms_inline_editor"
require "rails"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module InlineEditor

    class Engine < Rails::Engine
      #puts "#{self}"

      #puts "config.action_view.javascript_expansions=#{config.action_view.javascript_expansions.inspect}"
      config.action_view.javascript_expansions[:k3].concat [
        'css_browser_selector.js',
        'inline_editor.js',
        'k3cms/inline_editor.js',
      ]
      config.action_view.stylesheet_expansions[:k3].concat [
        'k3cms/inline_editor.css',
      ]

      initializer 'k3.inline_editor.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end
    end

  end
end
