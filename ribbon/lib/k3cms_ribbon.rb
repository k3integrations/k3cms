$:.unshift File.join(File.dirname(__FILE__), '..')  # so we can require 'app/models/k3cms/...'

require 'k3cms/ribbon/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

module K3cms
  module Ribbon
    autoload :ControllerMethods, 'k3cms/ribbon/controller_methods'
  end
end
