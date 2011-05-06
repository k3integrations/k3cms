# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'pathname'
require Pathname.new(__FILE__).dirname + "../lib/k3cms/version"

Gem::Specification.new do |s|
  s.name        = "k3cms_pages"
  s.version     = K3cms::Version
  s.platform    = Gem::Platform::RUBY
  s.summary     = "K3cms Static Pages"
  s.description = 'Provides the ability to create static pages in a website'
  s.authors     = `git shortlog --summary --numbered         | awk '{print $2, $3    }'`.split("\n")
  s.email       = `git shortlog --summary --numbered --email | awk '{print $2, $3, $4}'`.split("\n")
  s.homepage    = 'http://www.k3integrations.com'

  s.add_dependency 'facets'
  s.add_dependency 'rails',        '~> 3.0.0'
  s.add_dependency 'activerecord', '~> 3.0.0'
  s.add_dependency 'actionpack',   '~> 3.0.0'
  s.add_dependency 'cells'
  s.add_dependency 'attribute_normalizer'
  s.add_dependency 'k3cms_core'
  s.add_dependency 'cancan'
  s.add_dependency 'haml', '= 3.0.25'
  s.add_dependency 'k3cms_authorization'

  s.add_development_dependency 'rspec', '~> 2.2.0'
  s.add_development_dependency 'rspec-rails', '~> 2.2.0'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'ruby-debug19'
  s.add_development_dependency 'k3cms_trivial_authorization'
  s.add_development_dependency 'devise'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
