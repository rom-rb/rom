require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task default: [:ci]

desc "Run CI tasks"
task ci: [:spec, :lint]

desc "Run adapter lint tests against memory adapter"
task :lint do
  exec 'bundle exec ruby spec/test/memory_adapter_lint_test.rb'
end

begin
  require "rubocop/rake_task"

  Rake::Task[:default].enhance [:rubocop]

  RuboCop::RakeTask.new do |task|
    task.options << "--display-cop-names"
  end
rescue LoadError
end

desc "Run mutant against a specific subject"
task :mutant do
  subject = ARGV.last
  if subject == 'mutant'
    abort "usage: rake mutant SUBJECT\nexample: rake mutant ROM::Header"
  else
    opts = {
      'include' => 'lib',
      'require' => 'rom',
      'use' => 'rspec',
      'ignore-subject' => "#{subject}#respond_to_missing?"
    }.to_a.map { |k, v| "--#{k} #{v}" }.join(' ')

    exec("bundle exec mutant #{opts} #{subject}")
  end
end
