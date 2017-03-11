source 'https://rubygems.org'

gemspec

gem 'inflecto'

group :development do
  gem 'dry-equalizer', '~> 0.2'
  gem 'sqlite3', platforms: [:mri, :rbx]
  gem 'jdbc-sqlite3', platforms: :jruby
end

group :test do
  gem 'rom', git: 'https://github.com/rom-rb/rom.git', branch: 'update-dry-initializer'
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'update-dry-initializer'
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

gem 'dry-initializer', git: 'https://github.com/dry-rb/dry-initializer.git', branch: 'v1.3.0'
