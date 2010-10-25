require "k3_pages"
require "rails"

module K3Pages
  class Engine < Rails::Engine
    initializer 'k3_pages.add_cells_paths' do |app|
      Cell::Base.view_paths = Cell::Base.view_paths + [File.join(File.dirname(__FILE__),'..','..','app','cells'), File.join(File.dirname(__FILE__),'..','..','app','views')]
    end
  end
end
