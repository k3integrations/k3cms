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
  s.summary       = %q{K3cms}
  s.description   = %q{The K3cms is a set of Ruby gems for Rails developers to quickly develop awesome websites with content management and much more.}
  s.homepage      = "http://k3cms.org"

  s.authors       = `git shortlog --summary --numbered         | awk '{print $2, $3    }'`.split("\n")
  s.email         = `git shortlog --summary --numbered --email | awk '{print $2, $3, $4}'`.split("\n")

  k3cms_core_gems.each do |gem_name|
    s.add_dependency gem_name
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.version       = K3cms::Version
  s.platform      = Gem::Platform::RUBY
end