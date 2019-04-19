source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

unless defined?(COMPONENTS)
  COMPONENTS = %w(core repository changeset)
end

gem 'dry-equalizer', github: 'dry-rb/dry-equalizer', branch: 'master'
gem 'dry-logic', github: 'dry-rb/dry-logic', branch: 'master'
gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'
gem 'dry-struct', github: 'dry-rb/dry-struct', branch: 'master'

COMPONENTS.each do |component|
  gem "rom-#{component}", path: Pathname(__dir__).join(component).realpath
end

group :sql do
  gem 'sequel', '~> 5.0'
  gem 'sqlite3', platforms: :mri
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'jdbc-postgres', platforms: :jruby
  gem 'pg', platforms: :mri
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
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
