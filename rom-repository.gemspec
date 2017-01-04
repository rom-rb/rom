# encoding: utf-8

require File.expand_path('../lib/rom/repository/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-repository'
  gem.summary       = 'Repository abstraction for rom-rb'
  gem.description   = 'rom-repository adds support for auto-mapping and commands on top of rom-rb relations'
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica+oss@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Repository::VERSION.dup
  gem.files         = `git ls-files`.split("\n").reject { |name| name.include?('benchmarks') || name.include?('examples') || name.include?('bin/console') }
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'rom', '~> 3.0.0.beta'
  gem.add_runtime_dependency 'rom-mapper', '~> 0.4'
  gem.add_runtime_dependency 'dry-core', '~> 0.2', '>= 0.2.1'
  gem.add_runtime_dependency 'dry-struct', '~> 0.1'

  gem.add_development_dependency 'rake', '~> 11.2'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
