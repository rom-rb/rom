source 'https://rubygems.org'

gemspec

gem 'rom-support', git: 'https://github.com/rom-rb/rom-support.git', branch: 'master'
gem 'rom-mapper', git: 'https://github.com/rom-rb/rom-mapper.git', branch: 'master'

group :console do
  gem 'pry'
  gem 'pg', platforms: [:mri]
end

group :test do
  gem 'dry-equalizer'
  gem 'dry-struct'
  gem 'minitest'
  gem 'inflecto', '~> 0.0', '>= 0.0.2'

  platforms :mri do
    gem 'codeclimate-test-reporter', require: false
    gem 'simplecov', require: false
  end

  platforms :rbx do
    gem 'rubysl-bigdecimal'
  end
end

group :sql do
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'master'
  gem 'sequel'
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'sqlite3', platforms: [:mri, :rbx]
end

group :benchmarks do
  gem 'activerecord', '~> 5.0'
  gem 'benchmark-ips', '~> 2.2.0'
  gem 'rom-repository', git: 'https://github.com/rom-rb/rom-repository.git', branch: 'master'
end

group :tools do
  gem 'byebug', platform: :mri
end
