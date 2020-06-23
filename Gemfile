source "https://rubygems.org"

gemspec

eval_gemfile "Gemfile.devtools"

if ENV["USE_DRY_TRANSFORMER_MASTER"].eql?("true")
  gem "dry-transformer", github: "dry-rb/dry-transformer", branch: "master"
end

group :sql do
  gem "rom-sql", github: "rom-rb/rom-sql", branch: "master"
  # TODO: >= 5.32.0 breaks mysql schema inference in some cases
  gem "dry-monitor"
  gem "jdbc-postgres", platforms: :jruby
  gem "jdbc-sqlite3", platforms: :jruby
  gem "pg", platforms: :ruby
  gem "sequel", "5.31.0"
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
