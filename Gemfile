source 'https://rubygems.org'

gemspec

gem 'rom-support', github: 'rom-rb/rom-support', branch: 'master'

group :test do
  gem 'anima'
  gem 'virtus'
  gem 'inflecto', '~> 0.0', '>= 0.0.2'

  platforms :rbx do
    gem 'codeclimate-test-reporter', require: false
  end
end

group :benchmarks do
  gem 'benchmark-ips', '~> 2.2.0'
end

group :tools do
  gem 'rubocop', '~> 0.31'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  gem 'byebug'

  platform :mri do
    gem 'mutant', '>= 0.8.0', github: 'mbj/mutant', branch: 'master'
    gem 'mutant-rspec'
  end
end
