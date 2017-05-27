require File.expand_path('../lib/rom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom'
  gem.summary       = 'Ruby Object Mapper'
  gem.description   = 'Persistence and mapping toolkit for Ruby'
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::VERSION.dup
  gem.files         = `git ls-files`.split("\n").reject { |name| name.include?('benchmarks') }
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'rom-core', '~> 1.0'
  gem.add_runtime_dependency 'rom-mapper', '~> 0.5', '>= 0.5.1'
  gem.add_runtime_dependency 'rom-repository', '~> 1.0'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
