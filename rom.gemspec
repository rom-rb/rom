require File.expand_path('../lib/rom/version', __FILE__)

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
    'source_code_uri'   => 'https://github.com/rom-rb/rom',
    'documentation_uri' => 'https://api.rom-rb.org/rom/',
    'mailing_list_uri'  => 'https://discourse.rom-rb.org/',
    'bug_tracker_uri'   => 'https://github.com/rom-rb/rom/issues',
  }

  gem.add_runtime_dependency 'rom-core', '~> 5.1', '>= 5.1.1'
  gem.add_runtime_dependency 'rom-repository', '~> 5.1'
  gem.add_runtime_dependency 'rom-changeset', '~> 5.1'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
