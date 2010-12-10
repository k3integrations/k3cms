require "k3_inline_editor"
require "rails"
require 'facets'
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module InlineEditor

    class Engine < Rails::Engine
      initializer 'k3.inline_editor.add_cells_paths' do |app|
        Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      end
    end

  end
end
