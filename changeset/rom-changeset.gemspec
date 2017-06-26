require File.expand_path('../lib/rom/changeset/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-changeset'
  gem.summary       = 'Changeset abstraction for rom-rb'
  gem.description   = 'rom-changeset adds support for preprocessing data on top of rom-rb repositories'
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica+oss@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Changeset::VERSION.dup
  gem.files         = `git ls-files`.split("\n").reject { |name| name.include?('benchmarks') || name.include?('examples') || name.include?('bin/console') }
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_dependency 'dry-core', '~> 0.3', '>= 0.3.1'
  gem.add_runtime_dependency 'rom-mapper', '~> 1.0'
  gem.add_dependency 'transproc', '~> 1.0'

  gem.add_development_dependency 'rake', '~> 11.2'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
