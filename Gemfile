source 'https://rubygems.org'

gemspec

gem 'inflecto'

group :development do
  gem 'dry-equalizer', '~> 0.2'
  gem 'sqlite3', platforms: [:mri, :rbx]
  gem 'jdbc-sqlite3', platforms: :jruby
end

group :test do
  gem 'rom', git: 'https://github.com/rom-rb/rom.git'
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git'
  gem 'rspec'
  gem 'dry-struct'
  gem 'byebug', platforms: :mri
  gem 'pg', platforms: [:mri, :rbx]
  gem 'jdbc-postgres', platforms: :jruby

  platform :mri do
    gem 'codeclimate-test-reporter', require: false
    gem 'simplecov'
  end
end

group :benchmarks do
  gem 'hotch', platforms: :mri
  gem 'benchmark-ips'
  gem 'activerecord', '~> 5.0'
end

group :tools do
  gem 'pry'
  gem 'mutant'
  gem 'mutant-rspec'
end
