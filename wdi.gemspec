# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wdi/version'

Gem::Specification.new do |spec|
  spec.name          = "wdi"
  spec.version       = Wdi::VERSION
  spec.authors       = ["Philip Hughes"]
  spec.email         = ["pj@ga.co"]
  spec.summary       = %q{A utility for dealing with and configuring the WDI folder and command line tools.}
  spec.homepage      = "https://github.com/ga-instructors/wdi-gem"
  spec.license       = "BSD 3-Clause"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", ">= 0.0"
  spec.add_development_dependency "pry", ">= 0.0"

  spec.add_runtime_dependency "thor", "~> 0.19"
end
