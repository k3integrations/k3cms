$:.unshift File.join(File.dirname(__FILE__), '..')  # so we can require 'app/models/k3/...'

require 'k3/ribbon/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

module K3
  module Ribbon
  end
end
