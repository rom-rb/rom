# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec:rom") do |t|
  t.pattern = ["spec/suite/rom/**/*_spec.rb"]
end

RSpec::Core::RakeTask.new("spec:legacy") do |t|
  t.pattern = ["spec/suite/legacy/**/*_spec.rb"]
end

RSpec::Core::RakeTask.new("spec:compat") do |t|
  t.pattern = ["spec/suite/compat/**/*_spec.rb"]
end

desc "Run all spec examples from all groups"
task spec: ["spec:rom", "spec:legacy", "spec:compat"]

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
    ENV["VERIFY"] = "true"
    ENV["COUNT"] = "1"
    Rake::Task[:benchmark].invoke
  end
end

# rubocop:disable Lint/SuppressedException
begin
  require "yard-junk/rake"
  YardJunk::Rake.define_task(:text)
rescue LoadError
end
# rubocop:enable Lint/SuppressedException
