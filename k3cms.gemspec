# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "k3cms/version"

k3cms_core_gems = %w[
  k3cms_core
  k3cms_pages 
  k3cms_ribbon 
  k3cms_inline_editor 
  k3cms_authorization 
]

Gem::Specification.new do |s|
  s.name          = "k3cms"
  s.description   = %q{K3cms is a complete Content Management System (CMS) for Rails 3, designed to enable to people to quickly launch websites that can be easily managed by non-technical end users while providing advanced features for software developers and graphics professionals.}
  s.summary       = %q{A Content Management System for Rails 3}

  s.homepage      = "http://k3cms.org"

  s.authors       = `git shortlog --summary --numbered         | awk '{print $2, $3    }'`.split("\n")
  s.email         = `git shortlog --summary --numbered --email | awk '{print $2, $3, $4}'`.split("\n")

  k3cms_core_gems.each do |gem_name|
    s.add_dependency gem_name
  end
  s.add_dependency 'rake', '0.8.7'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.version       = K3cms::Version
  s.platform      = Gem::Platform::RUBY
end
