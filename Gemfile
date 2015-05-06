source 'https://rubygems.org'

gemspec

gem 'transproc', github: 'solnic/transproc', branch: 'master'

group :console do
  gem 'pry'
  gem 'pg', platforms: [:mri]
end

group :test do
  gem 'virtus'
  gem 'anima'
  gem 'minitest'
  gem 'thread_safe'
  gem 'activesupport'
  gem 'inflecto', '~> 0.0', '>= 0.0.2'

  platforms :rbx do
    gem 'rubysl-bigdecimal', platforms: :rbx
    gem 'codeclimate-test-reporter', require: false
  end
end

group :sql do
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'master'
  gem 'sequel'
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'sqlite3', platforms: [:mri, :rbx]
end

group :benchmarks do
  gem 'activerecord', '4.2.0'
  gem 'benchmark-ips', git: 'https://github.com/evanphx/benchmark-ips.git', branch: 'master'
end

group :tools do
  gem 'rubocop'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  gem 'byebug'

  platform :mri do
    gem 'mutant', '>= 0.7.7'
    gem 'mutant-rspec'
  end
end
