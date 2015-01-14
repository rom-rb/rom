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

  gem.add_runtime_dependency 'addressable', '~> 2.3'
  gem.add_runtime_dependency 'transproc',   '~> 0.1'
  gem.add_runtime_dependency 'equalizer',   '~> 0.0', '>= 0.0.9'
  gem.add_runtime_dependency 'concord',     '~> 0.1', '>= 0.1.4'
  gem.add_runtime_dependency 'charlatan',   '~> 0.1', '>= 0.1'
  gem.add_runtime_dependency 'inflecto',    '~> 0.0', '>= 0.0.2'
  gem.add_runtime_dependency 'thread_safe', '~> 0.3'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec-core', '~> 3.1'
  gem.add_development_dependency 'rspec-mocks', '~> 3.1'
  gem.add_development_dependency 'rspec-expectations', '~> 3.1'
  gem.add_development_dependency 'minitest', '~> 5.5'
end
