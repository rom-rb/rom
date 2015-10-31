# encoding: utf-8

require File.expand_path('../lib/rom/mapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "rom-mapper"
  gem.description   = "ROM mapper component"
  gem.summary       = gem.description
  gem.authors       = 'Piotr Solnica'
  gem.email         = 'piotr.solnica@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = [ 'lib' ]
  gem.version       = ROM::Mapper::VERSION.dup
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_dependency 'equalizer', '~> 0.0', '>= 0.0.10'
  gem.add_dependency 'rom-support', '~> 1.0.0.beta1'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.3'
end
