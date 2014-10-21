# encoding: utf-8

require 'rom'

include ROM

DB = Sequel.connect("sqlite::memory")

def seed(db = DB)
  db.run("CREATE TABLE users (id SERIAL, name STRING)")

  db[:users].insert(id: 1, name: 'Jane')
  db[:users].insert(id:2, name: 'Joe')
end

seed
