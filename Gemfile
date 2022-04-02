# frozen_string_literal: true

source "https://rubygems.org"

gemspec

eval_gemfile "Gemfile.devtools"

gem "dry-container", github: "dry-rb/dry-container", branch: "main"
gem "dry-configurable", "~> 0.14.0"

if ENV["USE_DRY_TRANSFORMER_MAIN"].eql?("true")
  gem "dry-transformer", github: "dry-rb/dry-transformer", branch: "main"
end

if ENV["USE_DRY_INITIALIZER_MAIN"].eql?("true")
  gem "dry-initializer", github: "dry-rb/dry-initializer", branch: "main"
end

gem "rom-sql", github: "rom-rb/rom-sql", branch: "main"

gem "dry-core", github: "dry-rb/dry-core", branch: "main"
gem "dry-monitor", github: "dry-rb/dry-monitor", branch: "main"
gem "dry-events", github: "dry-rb/dry-events", branch: "main"

gem "zeitwerk", github: "fxn/zeitwerk", branch: "main"

group :sql do
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
