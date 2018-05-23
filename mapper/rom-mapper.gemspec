require File.expand_path('../lib/rom/mapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-mapper'
  gem.description   = 'Standalone data mappers integrated with rom-rb'
  gem.summary       = gem.description
  gem.authors       = 'Piotr Solnica'
  gem.email         = 'piotr.solnica+oss@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Mapper::VERSION.dup
  gem.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  gem.add_runtime_dependency 'dry-core', '~> 0.3', '>= 0.3.1'
  gem.add_runtime_dependency 'dry-types', '~> 0.13.0'
  gem.add_runtime_dependency 'dry-struct', '~> 0.5.0'
  gem.add_runtime_dependency 'transproc', '~> 1.0'

  gem.add_development_dependency 'rake', '~> 11.3'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
