source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

unless defined?(COMPONENTS)
  COMPONENTS = %w(core repository changeset)
end

COMPONENTS.each do |component|
  gem "rom-#{component}", path: Pathname(__dir__).join(component).realpath
end

if ENV['USE_TRANSPROC_MASTER'].eql?('true')
  gem 'transproc', github: 'solnic/transproc', branch: 'master'
end

group :sql do
  gem 'sequel', '~> 5.0'
  gem 'sqlite3', platforms: :mri
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'jdbc-postgres', platforms: :jruby
  gem 'pg', platforms: :mri
  gem 'dry-monitor'

  if ENV['USE_ROM_SQL_MASTER'].eql?('true')
    gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
  else
    gem 'rom-sql', '~> 3.0'
  end
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'codacy-coverage', require: false
  gem 'simplecov', platforms: :mri
  gem 'warning'
end

group :docs do
  platform :mri do
    gem 'redcarpet'
    gem 'yard'
    gem 'yard-junk'
  end
end

group :tools do
  gem 'pry'
  gem 'pry-byebug', platforms: :mri
end

group :benchmarks do
  gem 'hotch', platforms: :mri
  gem 'benchmark-ips'
  gem 'activerecord', '~> 5.0'
end
