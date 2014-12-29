require "rspec/core/rake_task"
require "rubocop/rake_task"

task default: [:spec, :rubocop]

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new do |task|
  task.options << "--display-cop-names"
end
