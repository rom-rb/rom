#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler'

Bundler.require

require 'benchmark/ips'

require 'rom-sql'

require 'active_record'

def env
  ROM_ENV
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

  def user_json
    all
  end

  def with_tasks
    association_left_join(:tasks, select: [:id, :title])
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "rom"
)

class ARUser < ActiveRecord::Base
  self.table_name = :users
  has_many :tasks, class_name: 'ARTask', foreign_key: :user_id
end

class ARTask < ActiveRecord::Base
  self.table_name = :tasks
end

setup.relation(:tasks)

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
end

ROM_ENV = setup.finalize

COUNT = ENV.fetch('COUNT', 1000).to_i

USER_SEED = COUNT.times.map do |i|
  { :id    => i + 1,
    :name  => "name #{i}",
    :email => "email_#{i}@domain.com",
    :age   => i*10 }
end

TASK_SEED = USER_SEED.map do |user|
  3.times.map do |i|
    { user_id: user[:id], title: "Task #{i}" }
  end
end.flatten

def seed
  USER_SEED.each do |attributes|
    env.schema.users.insert(attributes)
  end

  TASK_SEED.each do |attributes|
    env.schema.tasks.insert(attributes)
  end
end

seed

puts "LOADED #{env.schema.users.count} users via ROM/Sequel"
puts "LOADED #{env.schema.tasks.count} tasks via ROM/Sequel"

USERS = ROM_ENV.read(:users).all

Benchmark.ips do |x|
  x.report("rom.read(:users).all.to_a") { USERS.to_a }
  x.report("ARUser.all.to_a") { ARUser.all.to_a }

  x.report("rom.read(:user_json).all.to_a") { ROM_ENV.read(:users).user_json.to_a.to_json }
  x.report("ARUser.all.map(&:as_json)") { ARUser.all.to_a.to_json }

  x.report("rom.read(:users).all.with_tasks.to_a") { USERS.with_tasks.to_a }
  x.report("ARUser.all.includes(:tasks).to_a") { ARUser.all.includes(:tasks).to_a }
end
