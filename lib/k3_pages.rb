require 'k3_pages/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

module K3
  module Pages
    autoload :ResponseTimer, 'k3/pages/response_timer'
  end
end
