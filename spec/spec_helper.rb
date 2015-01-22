# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rom'

root = Pathname(__FILE__).dirname

Dir[root.join('support/*.rb').to_s].each { |f| require f }
Dir[root.join('shared/*.rb').to_s].each { |f| require f }

ROM::Repository.disable_auto_registration!

# Helper to register a repository unless it is already registered
def register_repo(klass)
  return if ROM::Repository.registered.include?(klass)

  ROM::Repository.register(klass)
end

RSpec.configure do |config|
  config.before do
    @constants = Object.constants
    @repos = ROM::Repository.registered.dup
  end

  config.after do
    added_constants = Object.constants - @constants
    added_constants.each { |name| Object.send(:remove_const, name) }

    added_repos = ROM::Repository.registered - @repos
    added_repos.each { |repo| ROM::Repository.unregister(repo) }
  end
end
