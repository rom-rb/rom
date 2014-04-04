# encoding: utf-8

require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom'
  gem.summary       = 'Ruby Object Mapper'
  gem.description   = gem.summary
  gem.authors       = ['Piotr Solnica', 'Dan Kubb', 'Markus Schirp', 'Martin Gamsjaeger'].sort
  gem.email         = ['piotr.solnica@gmail.com', 'dan.kubb@gmail.com', 'mbj@schirp-dso.com', 'gamsnjaga@gmail.com'].sort
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::VERSION.dup
  gem.files         = `git ls-files`.split("\n").reject { |name| name.include?('benchmarks') }
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_dependency 'addressable',         '~> 2.3', '>= 2.3.3'
  gem.add_dependency 'concord',             '~> 0.1'
  gem.add_dependency 'descendants_tracker', '~> 0.0.3'
  gem.add_dependency 'abstract_type',       '~> 0.0.7'
  gem.add_dependency 'adamantium',          '~> 0.2'
  gem.add_dependency 'axiom',               '~> 0.2'
  gem.add_dependency 'axiom-optimizer',     '~> 0.2'
  gem.add_dependency 'charlatan',           '~> 0.1'
  gem.add_dependency 'morpher',             '~> 0.2'
end
