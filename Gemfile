source 'https://rubygems.org'

gemspec

gem 'concord', '~> 0.1', git: 'git@github.com:mbj/concord.git', branch: 'master'

group :test do
  gem 'axiom-memory-adapter', '~> 0.2'
  gem 'bogus', '~> 0.1'
  gem 'rubysl-bigdecimal', :platforms => :rbx
end

group :benchmarks do
  gem 'perftools.rb'
end

gem 'devtools', git: 'https://github.com/rom-rb/devtools.git', branch: 'master'
gem 'morpher', git: 'https://github.com/mbj/morpher.git', branch: 'master'

# Added by devtools
eval_gemfile 'Gemfile.devtools'
