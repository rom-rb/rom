desc 'Run all specs'
task spec: ['spec:core', 'spec:mapper', 'spec:repository']

namespace :spec do
  desc 'Run core specs'
  task :core do
    system 'cd core && bundle exec rake spec'
  end

  desc 'Run mapper specs'
  task :mapper do
    system 'cd mapper && bundle exec rake spec'
  end

  desc 'Run repository specs'
  task :repository do
    system 'cd repository && bundle exec rake spec'
  end
end
