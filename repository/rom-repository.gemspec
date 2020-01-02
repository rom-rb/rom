# frozen_string_literal: true

require File.expand_path('lib/rom/repository/version', __dir__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-repository'
  gem.summary       = 'Repository abstraction for rom-rb'
  gem.description   = gem.summary
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica+oss@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Repository::VERSION.dup
  gem.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  gem.license       = 'MIT'
  gem.metadata      = {
    'source_code_uri' => 'https://github.com/rom-rb/rom/tree/master/repository',
    'documentation_uri' => 'https://api.rom-rb.org/rom/',
    'mailing_list_uri' => 'https://discourse.rom-rb.org/',
    'bug_tracker_uri' => 'https://github.com/rom-rb/rom/issues',
  }

  gem.add_runtime_dependency 'dry-initializer', '~> 3.0', '>= 3.0.1'
  gem.add_runtime_dependency 'dry-core', '~> 0.4'
  gem.add_runtime_dependency 'rom-core', '~> 5.1', '>= 5.1.2'

  gem.add_development_dependency 'rake', '~> 11.2'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
