$:.unshift File.join(File.dirname(__FILE__), '..')  # so we can require 'app/models/k3/page'

require 'k3/pages/engine'

module K3
  module Pages
    autoload :CustomRouting, 'k3/pages/custom_routing'
    #autoload :PagesHelper,   'k3/pages/pages_helper'
  end
end
