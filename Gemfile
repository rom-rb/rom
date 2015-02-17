source 'https://rubygems.org'

gemspec

group :console do
  gem 'pry'
  gem 'pg', platforms: [:mri]
end

group :test do
  gem 'virtus'
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
  gem 'benchmark-ips'
end

group :tools do
  gem 'rubocop'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  gem 'byebug'

  # TODO: mutant-rspec blocks rspec upgrade re-add when it's bumped in mutant
  # platform :mri do
  #   gem 'mutant', '0.7.4'
  #   gem 'mutant-rspec'
  # end
end
