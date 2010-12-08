require "k3_ribbon"
require "rails"
require 'facets'
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3
  module Ribbon

  class Engine < Rails::Engine
    initializer 'k3.ribbon.add_cells_paths' do |app|
      Cell::Base.view_paths += [Pathname[__DIR__] + '../../../app/cells']
      #puts "Cell::Base.view_paths=#{Cell::Base.view_paths.inspect}"
    end
  end

  end
end
