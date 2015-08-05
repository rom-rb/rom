# encoding: utf-8

require File.expand_path('../lib/rom/repository/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-repository'
  gem.summary       = 'Repository for ROM with auto-mapping and relation extensions'
  gem.description   = gem.summary
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Repository::VERSION.dup
  gem.files         = `git ls-files`.split("\n").reject { |name| name.include?('benchmarks') }
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'anima', '~> 0.2', '>= 0.2'
  gem.add_runtime_dependency 'rom', '~> 0.8', '>= 0.8.1'
  gem.add_runtime_dependency 'rom-sql', '~> 0.5', '>= 0.5.3'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.3'
end
