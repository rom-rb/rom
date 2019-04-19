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
  gem.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "lib/**/*"]
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'dry-core', '~> 0.3', '>= 0.3.1'
  gem.add_runtime_dependency 'rom-core', '~> 5.0'
  gem.add_runtime_dependency 'transproc', '~> 1.0'

  gem.add_development_dependency 'rake', '~> 11.2'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
