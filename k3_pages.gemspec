# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "k3/pages/version"

Gem::Specification.new do |s|
  s.name        = "k3_pages"
  s.version     = K3::Pages::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "K3 Static Pages"
  s.description = 'Provides the ability to create static pages in a website'
  s.authors     = ['John Ash', 'Tyler Rick']
  s.email       = ['jash@k3integrations.com', 'tyler@k3integrations.com']
  s.homepage    = 'http://www.k3integrations.com'

  s.add_dependency 'k3_core'
  s.add_dependency 'rails',        '~> 3.0.0'
  s.add_dependency 'activerecord', '~> 3.0.0'
  s.add_development_dependency 'rspec', '~> 2.0.1'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'ruby-debug19'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
