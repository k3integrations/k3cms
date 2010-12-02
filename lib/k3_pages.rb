$:.unshift File.join(File.dirname(__FILE__), '..')  # so we can require 'app/models/k3/pages/page'

require 'k3_pages/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

module K3
  module Pages
    autoload :CustomRouting, 'k3/pages/custom_routing'
  end
end
