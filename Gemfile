# encoding: utf-8

source 'https://rubygems.org'

gemspec

group :test do
  gem 'bogus', '~> 0.1'
  gem 'rubysl-bigdecimal', :platforms => :rbx
end

group :development do
  gem 'devtools', git: 'https://github.com/rom-rb/devtools.git', branch: 'master'
end

# Added by devtools
eval_gemfile 'Gemfile.devtools'
