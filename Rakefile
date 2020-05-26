require "bundler/gem_tasks"

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

begin
  require 'yard-junk/rake'
  YardJunk::Rake.define_task(:text)
rescue LoadError;end