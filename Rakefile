require "bundler/gem_tasks"

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run benchmarks (tweak count via COUNT envvar)"
task :benchmark do
  FileList["benchmarks/**/*_bench.rb"].each do |bench|
    sh "ruby #{bench}"
  end
end

namespace :benchmark do
  desc "Verify benchmarks"
  task :verify do
    ENV['VERIFY'] = "true"
    ENV['COUNT'] = "1"
    Rake::Task[:benchmark].invoke
  end
end

begin
  require 'yard-junk/rake'
  YardJunk::Rake.define_task(:text)
rescue LoadError;end