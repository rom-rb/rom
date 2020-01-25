require "bundler/gem_tasks"

SPEC_RESULTS = {}

desc 'Run all specs'
task :spec do
  %w(core repository changeset rom).map do |name|
    Rake::Task["spec:#{name}"].execute
  end

  if SPEC_RESULTS.values.any? { |v| v.equal?(false) }
    abort("\nspecs failed\n")
  end
end

namespace :spec do
  desc 'Run rom specs'
  task :rom do
    SPEC_RESULTS[:rom] = system('bundle exec rspec spec/**/*_spec.rb')
  end

  desc 'Run core specs'
  task :core do
    SPEC_RESULTS[:core] = system('cd core && bundle exec rake spec')
  end

  desc 'Run repository specs'
  task :repository do
    SPEC_RESULTS[:repository] = system('cd repository && bundle exec rake spec')
  end

  desc 'Run changeset specs'
  task :changeset do
    SPEC_RESULTS[:changeset] = system('cd changeset && bundle exec rake spec')
  end
end

task default: :spec

begin
  require 'yard-junk/rake'
  YardJunk::Rake.define_task(:text)
rescue LoadError;end