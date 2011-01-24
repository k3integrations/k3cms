require "k3_inline_editor"
require "rails"
#require 'facets' # Causes an error in Rails!
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module InlineEditor

    class Engine < Rails::Engine
      #puts "#{self}"

      #puts "config.action_view.javascript_expansions=#{config.action_view.javascript_expansions.inspect}"
      config.action_view.javascript_expansions[:k3].concat [
        'inline_editor.js',
        'k3/inline_editor.js',
      ]

      initializer 'k3.inline_editor.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end
    end

  end
end
