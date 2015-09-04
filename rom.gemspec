# encoding: utf-8

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

  gem.add_runtime_dependency 'transproc', '~> 0.3', '>= 0.3.0'
  gem.add_runtime_dependency 'equalizer', '~> 0.0', '>= 0.0.9'
  gem.add_runtime_dependency 'rom-support', '~> 0.1', '>= 0.1.0'
  gem.add_runtime_dependency 'rom-mapper', '~> 0.2', '>= 0.2.0'
  gem.add_runtime_dependency 'unsound', '~> 0.0'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.3'
end
