require File.expand_path('../lib/rom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'rom'
  gem.summary     = 'Persistence and mapping toolkit for Ruby'
  gem.description = gem.summary
  gem.author      = 'Piotr Solnica'
  gem.email       = 'piotr.solnica+oss@gmail.com'
  gem.homepage    = 'http://rom-rb.org'
  gem.version     = ROM::VERSION.dup
  gem.files       = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  gem.license     = 'MIT'

  gem.add_runtime_dependency 'rom-core', '~> 4.1', '>= 4.1.3'
  gem.add_runtime_dependency 'rom-repository', '~> 2.0', '>= 2.0.2'
  gem.add_runtime_dependency 'rom-changeset', '~> 1.0', '>= 1.0.1'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
