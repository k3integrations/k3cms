require "k3_pages"
require "rails"
#require 'pp'
#require 'facets'
#require 'facets/kernel/__dir__'
#require 'facets/pathname'

module K3Pages
  class Engine < Rails::Engine
    initializer 'k3_pages.add_cells_paths' do |app|
      Cell::Base.view_paths = Cell::Base.view_paths + [File.join(File.dirname(__FILE__),'..','..','app','cells'), File.join(File.dirname(__FILE__),'..','..','app','views')]
    end
    initializer 'k3_pages.add_middleware' do |app|
      app.middleware.use K3::Pages::PageNotFound
    end
  end
end
