# encoding: utf-8

require 'rom'

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
  db.run("CREATE TABLE users (id SERIAL, name STRING)")

  db[:users].insert(id: 1, name: 'Jane')
  db[:users].insert(id:2, name: 'Joe')
end

def deseed(db = DB)
  db.drop_table? :users
end

Dir[Pathname(__FILE__).dirname.join('shared/*.rb').to_s].each { |f| puts f; require f }
