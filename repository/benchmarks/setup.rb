require 'bundler'

Bundler.require

require 'benchmark/ips'
require 'sequel'
require 'rom-sql'
require 'rom-repository'
require 'active_record'
require 'logger'
require 'hotch'
begin; require 'byebug'; rescue LoadError; end
require_relative 'gc_suite'

def benchmark(title)
  puts "\n"
  puts "=> benchmark: #{title}"
  puts "\n"
  Benchmark.ips do |x|
    x.config(suite: GCSuite.new)
    def x.verify(*); end

    def x.prepare(*); yield; end
    yield x
    x.compare!
  end
  hr
end

DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://localhost/rom_repository_bench')

setup = ROM::Configuration.new(:sql, DATABASE_URL)

conn = setup.default.connection

conn.drop_table?(:posts)
conn.drop_table?(:users)
conn.drop_table?(:tasks)
conn.drop_table?(:tags)

conn.create_table :users do
  primary_key :id
  String :name
  String :email
  Integer :age
end

conn.create_table :tasks do
  primary_key :id
  Integer :user_id
  String :title
end

ActiveRecord::Base.establish_connection(DATABASE_URL)

module AR
  class User < ActiveRecord::Base
    self.table_name = :users

    def self.by_name(name)
      select(:id, :name, :email, :age).where(name: name).order(:id)
    end
  end
end

module Sequel
  class User < Sequel::Model
    def self.by_name(name)
      select(:id, :name, :email, :age).where(name: name).order(:id)
    end
  end
end

module Relations
  class Users < ROM::Relation[:sql]
    schema(:users) do
      attribute :id, Types::Serial
      attribute :name, Types::String
      attribute :email, Types::String
      attribute :age, Types::Int
    end

    def by_id(id)
      where(id: id).limit(1)
    end

    def by_name(name)
      where(name: name).limit(1)
    end
  end

  class Tasks < ROM::Relation[:sql]
    schema(:tasks) do
      attribute :id, Types::Serial
      attribute :user_id, Types::ForeignKey(:users)
      attribute :title, Types::String
    end
  end
end

setup.register_relation(Relations::Users)
setup.register_relation(Relations::Tasks)

class UserRepo < ROM::Repository[:users]
  commands :create, update: :by_id

  def [](id)
    users.where(id: id).one!
  end
end

ROM_ENV = ROM.container(setup)

COUNT = ENV.fetch('COUNT', 1000).to_i

USER_SEED = COUNT.times.map { |i|
  { id: i + 1,
    name: "User #{i + 1}",
    email: "email_#{i}@domain.com",
    age: i * 10 }
}

def hr
  '*' * 80
end

def rom
  ROM_ENV
end

def users
  rom.relations[:users]
end

def user_repo
  @user_repo ||= UserRepo.new(rom)
end
