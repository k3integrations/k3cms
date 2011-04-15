require 'k3cms/authorization/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3
require 'k3cms/authorization/engine_additions'
require 'k3cms/authorization/authorization_set'
require 'k3cms/authorization/parser'
require 'k3cms/authorization/permission_set'
require 'k3cms/authorization/exceptions'
require 'k3cms/authorization/general_controller_methods'