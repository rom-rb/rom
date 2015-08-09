require "rspec/core/rake_task"
require "rake/testtask"

RSpec::Core::RakeTask.new(:spec)
task default: [:ci]

desc 'Run specs in isolation'
task :"spec:isolation" do
  FileList["spec/**/*_spec.rb"].each do |spec|
    sh "rspec", spec
  end
end

desc "Run CI tasks"
task ci: [:spec]
