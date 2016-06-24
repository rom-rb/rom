source 'https://rubygems.org'

gemspec

gem 'inflecto'
gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'

gem 'rom', github: 'rom-rb/rom', branch: 'master'
gem 'rom-support', github: 'rom-rb/rom-support', branch: 'master'

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
  gem 'benchmark-ips'
end

group :tools do
  gem 'pry'
end
