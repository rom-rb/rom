# frozen_string_literal: true

require 'bundler/gem_tasks'

spec_results = {}

desc 'Run all specs'
task :spec do
  %w[core repository changeset rom].map do |name|
    Rake::Task["spec:#{name}"].execute
  end

  if spec_results.values.any? { |v| v.equal?(false) }
    abort("\nspecs failed\n")
  end
end

namespace :spec do
  desc 'Run rom specs'
  task :rom do
    spec_results[:rom] = system('bundle exec rspec spec/**/*_spec.rb')
  end

  desc 'Run core specs'
  task :core do
    spec_results[:core] = system('cd core && bundle exec rake spec')
  end

  desc 'Run repository specs'
  task :repository do
    spec_results[:repository] = system('cd repository && bundle exec rake spec')
  end

  desc 'Run changeset specs'
  task :changeset do
    spec_results[:changeset] = system('cd changeset && bundle exec rake spec')
  end
end

task default: :spec

begin
  require 'yard-junk/rake'
  YardJunk::Rake.define_task(:text)
rescue LoadError
  # ignore
end
