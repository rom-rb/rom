# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "rom-mapper"
  gem.description   = "rom-mapper"
  gem.summary       = gem.description
  gem.authors       = 'Piotr Solnica'
  gem.email         = 'piotr.solnica@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = [ 'lib' ]
  gem.version       = ROM::Mapper::VERSION.dup
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_dependency 'concord',             '~> 0.1'
  gem.add_dependency 'equalizer',           '~> 0.0.7'
  gem.add_dependency 'descendants_tracker', '~> 0.0.1'
  gem.add_dependency 'abstract_type',       '~> 0.0.5'
  gem.add_dependency 'adamantium',          '~> 0.1'
end
