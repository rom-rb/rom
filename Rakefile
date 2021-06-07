# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec:all") do |t|
  t.pattern = ["spec/unit/**/*_spec.rb", "spec/integration/**/*_spec.rb"]
end

RSpec::Core::RakeTask.new("spec:compat") do |t|
  t.pattern = ["spec/compat/**/*_spec.rb"]
end

task "spec" => ["spec:all", "spec:compat"]

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
