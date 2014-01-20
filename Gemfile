# encoding: utf-8

source 'https://rubygems.org'

gemspec

gem 'adamantium', '~> 0.1', git: 'https://github.com/dkubb/adamantium.git', branch: 'master'
gem 'axiom',      '~> 0.1', git: 'https://github.com/dkubb/axiom.git',      branch: 'master'

group :test do
  gem 'bogus', '~> 0.1'
end

group :development do
  gem 'devtools', git: 'https://github.com/rom-rb/devtools.git'
end

# Added by devtools
eval_gemfile 'Gemfile.devtools'
