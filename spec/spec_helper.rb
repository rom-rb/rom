# encoding: utf-8

require 'rom'

include ROM

DB = Sequel.connect("sqlite::memory")

DB.run("CREATE TABLE users (id SERIAL, name STRING)")

DB[:users].insert(id: 1, name: 'Jane')
DB[:users].insert(id:2, name: 'Joe')
