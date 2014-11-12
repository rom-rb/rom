# encoding: utf-8

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rom'
require 'rom/adapter/memory'
require 'rom/adapter/sequel'
require 'rom/adapter/mongo'

include ROM

if defined? JRUBY_VERSION
  USING_JRUBY = true
else
  USING_JRUBY = false
end

if USING_JRUBY
  SEQUEL_TEST_DB_URI = "jdbc:sqlite::memory"
else
  SEQUEL_TEST_DB_URI = "sqlite::memory"
end

DB = Sequel.connect(SEQUEL_TEST_DB_URI)

def seed(db = DB)
  db.run("CREATE TABLE users (id INTEGER PRIMARY KEY, name STRING)")

  db[:users].insert(id: 1, name: 'Jane')
  db[:users].insert(id:2, name: 'Joe')
end

def deseed(db = DB)
  db.drop_table? :users
end

Dir[Pathname(__FILE__).dirname.join('shared/*.rb').to_s].each { |f| puts f; require f }

RSpec.configure do |config|
  config.before do
    @constants = Object.constants
  end

  config.after do
    (Object.constants - @constants).each { |name| Object.send(:remove_const, name) }
  end
end
