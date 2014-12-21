#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler'

Bundler.require

require 'benchmark/ips'

require 'rom-sql'

require 'active_record'

def rom
  ROM_ENV
end

def users
  rom.read(:users)
end

def tasks
  rom.read(:tasks)
end

def hr
  puts "*"*80
end

def run(title)
  puts "\n"
  puts "=> benchmark: #{title}"
  puts "\n"
  yield
  hr
end

setup = ROM.setup(pg: 'postgres://localhost/rom')

conn = setup.pg.connection

conn.drop_table?(:users)
conn.drop_table?(:tasks)

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

setup.relation(:users) do
  one_to_many :tasks, key: :user_id

  def all
    select(:id, :name, :email, :age).order(:users__id)
  end

  def first
    all.limit(1)
  end

  def user_json
    all
  end

  def with_tasks
    association_left_join(:tasks, select: [:id, :title])
  end
end

setup.relation(:tasks) do
  many_to_one :users, key: :user_id

  def all
    select(:id, :user_id, :title).order(:tasks__id)
  end

  def with_user
    association_join(:users, select: [:id, :name, :email, :age])
  end
end


ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "rom"
)

class ARUser < ActiveRecord::Base
  self.table_name = :users
  has_many :tasks, class_name: 'ARTask', foreign_key: :user_id
end

class ARTask < ActiveRecord::Base
  self.table_name = :tasks
  belongs_to :user, class_name: 'ARUser', foreign_key: :user_id
end

setup.mappers do
  define(:users) do
    model name: 'User'
  end

  define(:with_tasks, parent: :users) do
    model name: 'UserWithTasks'

    group :tasks do
      model name: 'UserTask'
      attribute :id, from: :tasks_id
      attribute :title
    end
  end

  define(:user_json, parent: :users)

  define(:tasks) do
    model name: 'Task'

    wrap :user do
      model name: 'TaskUser'

      attribute :id, from: :users_id
      attribute :name
      attribute :email
      attribute :age
    end
  end
end

ROM_ENV = setup.finalize

COUNT = ENV.fetch('COUNT', 1000).to_i

USER_SEED = COUNT.times.map do |i|
  { id:    i + 1,
    name:  "name #{i}",
    email: "email_#{i}@domain.com",
    age:   i*10 }
end

TASK_SEED = USER_SEED.map do |user|
  3.times.map do |i|
    { user_id: user[:id], title: "Task #{i}" }
  end
end.flatten

def seed
  USER_SEED.each do |attributes|
    rom.schema.users.insert(attributes)
  end

  TASK_SEED.each do |attributes|
    rom.schema.tasks.insert(attributes)
  end
end

seed

hr
puts "INSERTED #{rom.schema.users.count} users via ROM/Sequel"
puts "INSERTED #{rom.schema.tasks.count} tasks via ROM/Sequel"
hr

run("Loading ONE user object") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.first }
    x.report("ROM") { users.first }
    x.compare!
  end
end

run("Loading 1k user objects") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.all.to_a }
    x.report("ROM") { users.all.to_a }
    x.compare!
  end
end

run("Loading 1k user objects with tasks") do
  Benchmark.ips do |x|
    x.report("AR") { ARTask.all.includes(:user).to_a }
    x.report("ROM") { tasks.with_user.to_a }
    x.compare!
  end
end

run("Loading 3k task objects with users") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.all.includes(:tasks).to_a }
    x.report("ROM") { users.all.with_tasks.to_a }
    x.compare!
  end
end

run("to_json on 1k user objects") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.all.to_a.to_json }
    x.report("ROM") { users.user_json.to_a.to_json }
    x.compare!
  end
end
