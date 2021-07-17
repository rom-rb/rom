# frozen_string_literal: true

source "https://rubygems.org"

gemspec

eval_gemfile "Gemfile.devtools"

gem "dry-container", github: "dry-rb/dry-container", branch: "master"
gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "master"

if ENV["USE_DRY_TRANSFORMER_MASTER"].eql?("true")
  gem "dry-transformer", github: "dry-rb/dry-transformer", branch: "master"
end

if ENV["USE_DRY_INITIALIZER_MASTER"].eql?("true")
  gem "dry-initializer", github: "dry-rb/dry-initializer", branch: "master"
end

gem "rom-sql", github: "rom-rb/rom-sql", branch: "update-to-rom6"

gem "dry-core", github: "dry-rb/dry-core", branch: "master"
gem "dry-monitor", github: "dry-rb/dry-monitor", branch: "master"
gem "dry-events", github: "dry-rb/dry-events", branch: "master"

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
