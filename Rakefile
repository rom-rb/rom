require "rspec/core/rake_task"
require "rake/testtask"

RSpec::Core::RakeTask.new(:spec)
task default: [:ci]

desc "Run CI tasks"
task ci: [:spec, :lint]

Rake::TestTask.new(:lint) do |test|
  test.description = "Run adapter lint tests against memory adapter"
  test.test_files = FileList.new('spec/test/*_test.rb')
  test.libs << 'test'
  test.verbose = true
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
