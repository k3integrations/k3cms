# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "k3/authorization/version"

Gem::Specification.new do |s|
  s.name        = "k3_authorization"
  s.summary     = %q{Provides the basic system for engines to load their own authorization settings}
  s.description = %q{This gem extends Rails::Engine to look for and load a /config/authorization.rb file.  An authorization system will then make use of those settings.  This gem provides the foundation upon which an authorization gem can be built.}
  s.homepage      = "http://k3cms.org/#{s.name}"

  s.authors       = `git shortlog --summary --numbered         | awk '{print $2, $3    }'`.split("\n")
  s.email         = `git shortlog --summary --numbered --email | awk '{print $2, $3, $4}'`.split("\n")

  s.add_dependency 'k3_core'
  s.add_dependency 'rails',        '~> 3.0.0'
  s.add_dependency 'activesupport', '~> 3.0.0'

  s.add_development_dependency 'rspec', '~> 2.2.0'
  s.add_development_dependency 'rspec-rails', '~> 2.2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.version       = K3::Authorization::Version
  s.platform      = Gem::Platform::RUBY
end
