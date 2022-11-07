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

group :sql do
  gem 'sequel', '~> 5.0'
  gem 'sqlite3', platforms: :ruby
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'jdbc-postgres', platforms: :jruby
  gem 'pg', platforms: :ruby
  gem 'dry-events', '~> 1.0'
  gem 'dry-monitor', '~> 1.0'

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
