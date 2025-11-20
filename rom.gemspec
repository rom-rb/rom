# frozen_string_literal: true

require File.expand_path('lib/rom/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'rom'
  gem.summary     = 'Persistence and mapping toolkit for Ruby'
  gem.description = gem.summary
  gem.author      = 'Piotr Solnica'
  gem.email       = 'piotr.solnica+oss@gmail.com'
  gem.homepage    = 'http://rom-rb.org'
  gem.version     = ROM::VERSION.dup
  gem.files       = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  gem.license     = 'MIT'
  gem.metadata    = {
    'source_code_uri' => 'https://github.com/rom-rb/rom',
    'documentation_uri' => 'https://api.rom-rb.org/rom/',
    'mailing_list_uri' => 'https://discourse.rom-rb.org/',
    'bug_tracker_uri' => 'https://github.com/rom-rb/rom/issues',
    'rubygems_mfa_required' => 'true'
  }

  gem.add_dependency 'rom-changeset', '~> 5.4'
  gem.add_dependency 'rom-core', '~> 5.4'
  gem.add_dependency 'rom-repository', '~> 5.4', '>= 5.4.3'
end
