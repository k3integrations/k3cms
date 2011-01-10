# -*- encoding: utf-8 -*-
# $:.push File.expand_path("../lib", __FILE__)
# require "k3_authorization/version"

Gem::Specification.new do |s|
  s.name        = "k3_authorization"
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Ash"]
  s.email       = ["jash@k3integrations.com"]
  s.homepage    = "http://k3cms.org/documentation/k3_authorization"
  s.summary     = %q{Provides the basic system for engines to load their own authorization settings}
  s.description = %q{This gem extends Rails::Engine to look for and load a /config/authorization.rb file.  An authorization system will then make use of those settings.  This gem provides the foundation upon which an authorization gem can be built.}
#  s.add_runtime_dependency('k3_core', [">= 0"])
  s.add_runtime_dependency('activesupport', ['>= 2'])
  s.add_runtime_dependency('i18n')
  s.add_development_dependency('rspec', [">= 2"])
  
#  s.rubyforge_project = "k3_authorization"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
