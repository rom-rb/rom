source 'https://rubygems.org'

gemspec

group :test do
  gem 'axiom-memory-adapter', '~> 0.2'
  gem 'bogus', '~> 0.1'
  gem 'rubysl-bigdecimal', :platforms => :rbx
end

group :benchmarks do
  gem 'perftools.rb'
end

gem 'devtools', git: 'https://github.com/rom-rb/devtools.git', branch: 'master'

# Added by devtools
eval_gemfile 'Gemfile.devtools'
