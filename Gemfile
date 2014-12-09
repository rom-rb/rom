source 'https://rubygems.org'

gemspec

group :console do
  gem 'pry'
  gem 'pg'
end

group :test do
  gem 'virtus'
  gem 'guard'
  gem 'guard-rspec'

  platforms :rbx do
    gem 'rubysl-bigdecimal', platforms: :rbx
    gem 'codeclimate-test-reporter', require: false
  end

  platforms :mri do
    gem 'mutant'
    gem 'mutant-rspec'
  end
end

group :sql do
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'master'
  gem 'sequel'
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'sqlite3', platforms: [:mri, :rbx]
end

group :benchmarks do
  gem 'activerecord'
  gem 'benchmark-ips'
end
