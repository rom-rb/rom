source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

unless defined?(COMPONENTS)
  COMPONENTS = %w(core repository changeset)
end

gem 'dry-types', github: 'dry-rb/dry-types'
gem 'dry-struct', github: 'dry-rb/dry-struct'

COMPONENTS.each do |component|
  gem "rom-#{component}", path: Pathname(__dir__).join(component).realpath
end

group :sql do
  gem 'sequel', '~> 5.0'
  gem 'sqlite3', platforms: [:mri, :rbx]
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'pg', platforms: [:mri, :rbx]
  gem 'jdbc-postgres', platforms: :jruby
  gem 'rom-sql', github: 'rom-rb/rom-sql'
  gem 'dry-monitor'
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'simplecov', platforms: :mri
end

group :tools do
  gem 'pry-byebug', platforms: :mri
  gem 'pry', platforms: :jruby
  gem 'redcarpet', platforms: :mri # for yard
end

group :benchmarks do
  gem 'hotch', platforms: :mri
  gem 'benchmark-ips'
  gem 'activerecord', '~> 5.0'
end
