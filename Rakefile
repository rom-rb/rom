require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require "rubocop/rake_task"
rescue LoadError; end

if defined?(RuboCop)
  task default: [:spec, :rubocop]

  RuboCop::RakeTask.new do |task|
    task.options << "--display-cop-names"
  end
else
  task default: [:spec]
end

desc "Run mutant against a specific subject"
task :mutant do
  subject = ARGV.last
  cmd = "mutant --include lib --require ./spec/spec_helper --use rspec #{subject}"
  exec(cmd)
end
