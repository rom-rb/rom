source 'https://rubygems.org'

gemspec

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
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'release-1.0'
  gem 'sequel'
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'jdbc-postgres', platforms: :jruby
  gem 'sqlite3', platforms: [:mri, :rbx]

  git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

  platform :jruby do
    github 'jruby/activerecord-jdbc-adapter', branch: 'rails-5' do
      gem 'activerecord-jdbc-adapter'
      gem 'activerecord-jdbcpostgresql-adapter'
    end
  end
end

group :benchmarks do
  gem 'activerecord', '~> 5.0'
  gem 'benchmark-ips', '~> 2.2.0'
  gem 'rom-repository', git: 'https://github.com/rom-rb/rom-repository.git', branch: 'master'
  gem 'hotch', platform: :mri
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'mutant'
  gem 'mutant-rspec'
end
