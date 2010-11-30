require 'k3_pages/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

module K3
  module Pages
    autoload :PageNotFound, 'k3/pages/page_not_found'
  end
end
