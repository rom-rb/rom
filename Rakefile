require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task default: [:spec]

begin
  require "rubocop/rake_task"
  Rake::Task['default'].enhance [:rubocop]

  RuboCop::RakeTask.new do |task|
    task.options << "--display-cop-names"
  end
rescue LoadError
end

desc "Run mutant against a specific subject"
task :mutant do
  subject = ARGV.last
  cmd = "mutant --include lib --require ./spec/spec_helper --use rspec #{subject}"
  exec(cmd)
end
