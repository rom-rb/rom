source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

unless defined?(COMPONENTS)
  COMPONENTS = %w(core repository changeset)
end

COMPONENTS.each do |component|
  gem "rom-#{component}", path: Pathname(__dir__).join(component).realpath
end

if ENV['USE_TRANSPROC_MASTER'].eql?('true')
  gem 'transproc', github: 'solnic/transproc', branch: 'master'
end

gem 'dry-configurable', github: 'dry-rb/dry-configurable', branch: 'main'
gem 'dry-core', github: 'dry-rb/dry-core', branch: 'main'
gem 'dry-inflector', github: 'dry-rb/dry-inflector', branch: 'main'
gem 'dry-logic', github: 'dry-rb/dry-logic', branch: 'main'
gem 'dry-types', github: 'dry-rb/dry-types', branch: 'main'
gem 'dry-struct', github: 'dry-rb/dry-struct', branch: 'main'

group :sql do
  gem 'sequel', '~> 5.0'
  gem 'sqlite3', platforms: :ruby
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'jdbc-postgres', platforms: :jruby
  gem 'pg', platforms: :ruby
  gem 'dry-events', github: 'dry-rb/dry-events', branch: 'main'
  gem 'dry-monitor', github: 'dry-rb/dry-monitor', branch: 'main'

  # if ENV['USE_ROM_SQL_MASTER'].eql?('true')
  #   gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
  # else
  #   gem 'rom-sql', '~> 3.0'
  # end
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'release-3.6'
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'codacy-coverage', require: false
  gem 'simplecov', platforms: :ruby
  gem 'warning'
end

group :docs do
  platform :ruby do
    gem 'redcarpet'
    gem 'yard'
    gem 'yard-junk'
  end
end

group :tools do
  gem 'pry'
  gem 'pry-byebug', platforms: :ruby
end

group :benchmarks do
  gem 'hotch', platforms: :ruby
  gem 'benchmark-ips'
  gem 'activerecord', '~> 5.0'
end
