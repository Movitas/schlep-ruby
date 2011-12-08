# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schlep/version"

Gem::Specification.new do |s|
  s.name        = "schlep"
  s.version     = Schlep::VERSION
  s.authors     = ["Justin Campbell"]
  s.email       = ["justin@justincampbell.me"]
  s.homepage    = "http://github.com/Movitas/schlep-ruby"
  s.summary     = %q{Ruby client for schlep http://github.com/Movitas/schlep}
  s.description = %q{Ruby client for schlep. Schlep provides a simple interface for logging and broadcasting events.}

  s.rubyforge_project = "schlep"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "redis"

  s.add_development_dependency "guard-test"
  s.add_development_dependency "shoulda"
end
