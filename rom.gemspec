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
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_dependency 'rom-relation', '~> 0.1.0'
  gem.add_dependency 'rom-mapper',   '~> 0.1.0'
  gem.add_dependency 'rom-session',  '~> 0.1.0'
end
