#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler'

Bundler.require

require 'benchmark/ips'
require 'rom'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.string :email
    t.integer :age
  end
end

class ARUser < ActiveRecord::Base
  self.table_name = :users
end

def env
  ROM_ENV
end

ROM_ENV = ROM.setup(sqlite: 'sqlite::memory') do
  schema do
    base_relation :users do
      repository :sqlite

      attribute :id,    Integer
      attribute :name,  String
      attribute :email, String
      attribute :age,   Integer
    end
  end

  relations do
    users do
      def all
        order(:id)
      end
    end
  end

  mappers do
    users do
      all do
        model name: 'User'
      end
    end
  end
end

ROM_ENV.sqlite.connection.run("create table users (id SERIAL, name STRING, email STRING, age INT)")

COUNT = ENV.fetch('COUNT', 1000).to_i

SEED = COUNT.times.map do |i|
  { :id    => i + 1,
    :name  => "name #{i}",
    :email => "email_#{i}@domain.com",
    :age   => i*10 }
end

def seed
  SEED.each do |attributes|
    env.schema.users.insert(attributes)
    ARUser.create(attributes)
  end
end

seed

puts "LOADED #{env.schema.users.count} users via ROM/Sequel"
puts "LOADED #{ARUser.count} users via ActiveRecord"

USERS = ROM_ENV.read(:users).all

Benchmark.ips do |x|
  x.report("rom.relations.users.to_a") { ROM_ENV.relations.users.to_a }
  x.report("rom.reader(:users).all.to_a") { USERS.to_a }
  x.report("ARUser.all.to_a") { ARUser.all.to_a }
end
