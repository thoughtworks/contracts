# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contracts/version'

Gem::Specification.new do |gem|
  gem.name          = "contracts"
  gem.version       = Contracts::VERSION
  gem.authors       = ["ThoughtWorks & Abril"]
  gem.email         = ["abril_vejasp_dev@thoughtworks.com"]
  gem.description   = %q{Contracts is a Ruby implementation of the [Consumer-Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html) pattern for evolving services}
  gem.summary       = %q{Consumer-Driven Contracts implementation}
  gem.homepage      = 'https://github.com/thoughtworks/contracts'
  gem.license       = 'MIT'
  

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "webmock"
  gem.add_dependency "json"
  gem.add_dependency "json-schema"
  gem.add_dependency "json-generator"
  gem.add_dependency "hash-deep-merge"
  gem.add_dependency "httparty"
  gem.add_dependency "addressable"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rb-fsevent" if RUBY_PLATFORM =~ /darwin/i
end
