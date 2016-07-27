source 'https://rubygems.org'

gemspec

gem 'inflecto'

gem 'rom', github: 'rom-rb/rom', branch: 'master'

group :development, :test do
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
end

group :development do
  gem 'dry-equalizer', '~> 0.2'
  gem 'sqlite3', platforms: [:mri, :rbx]
  gem 'jdbc-sqlite3', platforms: :jruby
end

group :test do
  gem 'rspec'
  gem 'byebug', platforms: :mri
  gem 'pg', platforms: [:mri, :rbx]
  gem 'jdbc-postgres', platforms: :jruby
  gem 'codeclimate-test-reporter', require: nil
end

group :benchmarks do
  gem 'hotch', platforms: :mri
  gem 'benchmark-ips'
  gem 'activerecord', '~> 4.2'
end

group :tools do
  gem 'pry'
end
