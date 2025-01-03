# frozen_string_literal: true

require File.expand_path('lib/rom/changeset/version', __dir__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-changeset'
  gem.summary       = 'Changeset abstraction for rom-rb'
  gem.description   = 'rom-changeset adds support for preprocessing data on ' \
                      'top of rom-rb repositories'
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica+oss@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Changeset::VERSION.dup
  gem.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  gem.license       = 'MIT'
  gem.metadata      = {
    'source_code_uri' => 'https://github.com/rom-rb/rom/tree/master/changeset',
    'documentation_uri' => 'https://api.rom-rb.org/rom/',
    'mailing_list_uri' => 'https://discourse.rom-rb.org/',
    'bug_tracker_uri' => 'https://github.com/rom-rb/rom/issues',
    'rubygems_mfa_required' => 'true'
  }

  gem.add_dependency 'dry-core', '~> 1.0'
  gem.add_dependency 'rom-core', '~> 5.4'
  gem.add_dependency 'transproc', '~> 1.1'
end
