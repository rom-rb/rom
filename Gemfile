source 'https://rubygems.org'

gemspec

gem 'rom-mapper', :path => '.'

group :test do
  gem 'bogus', '~> 0.0.4'
end

group :development do
  gem 'devtools', :git => 'https://github.com/rom-rb/devtools.git'
  eval File.read('Gemfile.devtools')
end
