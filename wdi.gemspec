# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wdi/version'

Gem::Specification.new do |spec|
  spec.name          = "wdi"
  spec.version       = WDI::VERSION
  spec.authors       = ["Philip Hughes"]
  spec.email         = ["pj@ga.co"]
  spec.summary       = %q{A utility for working with (and configuring) the WDI directory and WDI command line tools.}
  spec.description   = %q{TBC}
  spec.homepage      = "https://github.com/ga-instructors/wdi-gem"
  spec.license       = "BSD 3-Clause"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake",    "~> 10.2"
  spec.add_development_dependency "rspec",   '~> 2.14', '>= 2.14.1'
  #spec.add_development_dependency "fakefs",  '~> 0.5',  '>= 0.5.2'
  spec.add_development_dependency "aruba",   '~> 0.5',  '>= 0.5.4'
  spec.add_development_dependency "pry",     '~> 0.9',  '>= 0.9.12'

  spec.add_runtime_dependency "thor", "~> 0.19"
end
