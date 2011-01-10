require 'k3/authorization/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3
require 'k3/authorization/engine_additions'
require 'k3/authorization/authorization_set'
require 'k3/authorization/parser'
require 'k3/authorization/permission_set'
require 'k3/authorization/exceptions'
require 'k3/authorization/general_controller_methods'