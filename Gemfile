source 'https://rubygems.org'

gemspec

group :console do
  gem 'pry'
  gem 'pg', platforms: [:mri]
end

group :test do
  gem 'virtus'
  gem 'anima', '~> 0.2.0'
  gem 'minitest'
  gem 'inflecto', '~> 0.0', '>= 0.0.2'

  platforms :rbx do
    gem 'rubysl-bigdecimal', platforms: :rbx
    gem 'codeclimate-test-reporter', require: false
  end
end

group :sql do
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
  gem 'sequel'
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'sqlite3', platforms: [:mri, :rbx]
end

group :benchmarks do
  gem 'activerecord', '5.0.0.beta4'
  gem 'benchmark-ips', '~> 2.2.0'
  gem 'rom-repository', github: 'rom-rb/rom-repository', branch: 'master'
end

group :tools do
  gem 'byebug', platform: :mri
end
