source "https://rubygems.org"

gemspec

eval_gemfile "Gemfile.devtools"

if ENV["USE_DRY_TRANSFORMER_MASTER"].eql?("true")
  gem "dry-transformer", github: "dry-rb/dry-transformer", branch: "master"
end

if ENV["USE_DRY_INITIALIZER_MASTER"].eql?("true")
  gem "dry-initializer", github: "dry-rb/dry-initializer", branch: "master"
end

gem "rom-sql", github: "rom-rb/rom-sql", branch: "master"

group :sql do
  gem "dry-monitor"
  gem "jdbc-postgres", platforms: :jruby
  gem "jdbc-sqlite3", platforms: :jruby
  gem "pg", platforms: :ruby
  gem "sqlite3", platforms: :ruby
end

group :test do
  gem "rspec", "~> 3.6"
end

group :docs do
  platform :ruby do
    gem "redcarpet"
    gem "yard"
    gem "yard-junk"
  end
end

group :tools do
  gem "pry"
  gem "pry-byebug", platforms: :ruby
end

group :benchmarks do
  gem "activerecord", "~> 5.0"
  gem "benchmark-ips"
  gem "hotch", platforms: :ruby
end
