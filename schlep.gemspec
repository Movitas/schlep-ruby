# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schlep/version"

Gem::Specification.new do |s|
  s.name        = "schlep"
  s.version     = Schlep::VERSION
  s.license     = "MIT"
  s.authors     = ["Justin Campbell"]
  s.email       = ["justin@justincampbell.me"]
  s.homepage    = "http://github.com/Movitas/schlep-ruby"
  s.summary     = %q{Ruby client for schlep http://github.com/Movitas/schlep}
  s.description = %q{Ruby client for schlep. Schlep provides a simple interface for logging and broadcasting events.}

  s.rubyforge_project = "schlep"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency "redis"

  if RUBY_VERSION =~ /1.8/
    s.add_runtime_dependency "json"
    s.add_runtime_dependency "system_timer"
  end

  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
