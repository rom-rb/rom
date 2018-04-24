source 'https://rubygems.org'

gemspec

unless defined?(COMPONENTS)
  COMPONENTS = %w(core mapper repository changeset)
end

COMPONENTS.each do |component|
  gem "rom-#{component}", path: Pathname(__dir__).join(component).realpath
end

gem 'dry-types', git: 'http://github.com/dry-rb/dry-types'
gem 'dry-struct', git: 'http://github.com/dry-rb/dry-struct'
gem 'dry-inflector', git: 'http://github.com/dry-rb/dry-inflector'

group :sql do
  gem 'sequel', '~> 5.0'
  gem 'sqlite3', platforms: [:mri, :rbx]
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'pg', platforms: [:mri, :rbx]
  gem 'jdbc-postgres', platforms: :jruby
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'master'
  gem 'dry-monitor'
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'inflecto'
  gem 'simplecov', platforms: :mri
end

group :tools do
  gem 'mutant'
  gem 'mutant-rspec'
  gem 'pry-byebug', platforms: :mri
  gem 'pry', platforms: :jruby
  gem 'redcarpet', platforms: :mri # for yard
end

group :benchmarks do
  gem 'hotch', platforms: :mri
  gem 'benchmark-ips'
  gem 'activerecord', '~> 5.0'
end
