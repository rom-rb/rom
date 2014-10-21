source 'https://rubygems.org'

gemspec

group :test do
  gem 'sqlite3', platforms: [:mri, :rbx]
  gem 'jdbc-sqlite3', platforms: :jruby
  gem 'rubysl-bigdecimal', platforms: :rbx
end

group :benchmarks do
  gem 'activerecord'
  gem 'benchmark-ips'
end
