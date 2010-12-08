require "k3_ribbon"
require "rails"
#require 'pp'
#require 'facets'
#require 'facets/kernel/__dir__'
#require 'facets/pathname'

module K3
  module Ribbon

  class Engine < Rails::Engine
    initializer 'k3.ribbon.something' do |app|
    end
  end

  end
end
