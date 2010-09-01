if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require File.dirname(__FILE__) + '/k3/engine' 
  require File.dirname(__FILE__) + '/k3/file_utils'
end