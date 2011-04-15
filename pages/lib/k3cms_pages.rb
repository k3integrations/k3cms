$:.unshift File.join(File.dirname(__FILE__), '..')  # so we can require 'app/models/k3cms/page'

require 'k3cms/pages/engine'

module K3cms
  module Pages
    autoload :CustomRouting, 'k3cms/pages/custom_routing'
    #autoload :PagesHelper,   'k3cms/pages/pages_helper'
  end
end
