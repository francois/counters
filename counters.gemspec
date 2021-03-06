# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "counters/version"

Gem::Specification.new do |s|
  s.name        = "counters"
  s.version     = Counters::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["François Beausoleil"]
  s.email       = ["francois@teksol.info"]
  s.homepage    = "https://github.com/francois/counters"
  s.summary     = %q{Provides an API to record any kind of metrics within your system}
  s.description = %q{Using the provided API, record metrics (such as number of hits to a particular controller, bytes in/out, compression ratio) within your system. Visualization is NOT provided within this gem.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Eventually, we might have something like this
  # s.add_optional_dependency "redis"
  s.add_development_dependency "redis"

  s.add_development_dependency "rspec"
  s.add_development_dependency "timecop"
  s.add_development_dependency "ruby-debug19"
end
