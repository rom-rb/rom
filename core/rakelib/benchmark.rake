desc "Run benchmarks (tweak count via COUNT envvar)"
task :benchmark do
  FileList["benchmarks/**/*_bench.rb"].each do |bench|
    sh "ruby #{bench}"
  end
end

namespace :benchmark do
  desc "Verify benchmarks"
  task :verify do
    ENV['VERIFY'] = "true"
    ENV['COUNT'] = "1"
    Rake::Task[:benchmark].invoke
  end
end
