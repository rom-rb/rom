require File.expand_path('../lib/rom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom'
  gem.summary       = 'Ruby Object Mapper'
  gem.description   = 'Persistence and mapping toolkit for Ruby'
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.version       = ROM::VERSION.dup
  gem.files         = ['lib/rom.rb', 'README.md']
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'rom-core', '~> 4.0.0.beta'
  gem.add_runtime_dependency 'rom-mapper', '~> 1.0.0.beta'
  gem.add_runtime_dependency 'rom-repository', '~> 2.0.0.beta'
  gem.add_runtime_dependency 'rom-changeset', '~> 1.0.0.beta'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
