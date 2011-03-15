# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "e9_tags/version"

Gem::Specification.new do |s|
  s.name        = "e9_tags"
  s.version     = E9Tags::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Travis Cox"]
  s.email       = ["travis@e9digital.com"]
  s.homepage    = "http://www.e9digital.com"
  s.summary     = %q{Extension to ActsAsTaggableOn used in e9 Rails 3 projects}
  s.description = File.open('README.md').read rescue nil

  s.rubyforge_project = "e9_tags"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("rails", "~> 3.0.0")
  s.add_dependency("acts-as-taggable-on", "~> 2.0.6")
end
