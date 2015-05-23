require 'bundler'

Bundler.require

require 'benchmark/ips'
require 'rom-sql'
require 'active_record'

begin
  require 'byebug'
rescue LoadError
end

require_relative 'gc_suite'

def rom
  ROM_ENV
end

def users
  @users ||= rom.relation(:users).as(:users)
end

def users_with_tasks
  @user_with_tasks ||= rom.relation(:users).with_tasks.as(:user_with_tasks)
end

def tasks
  rom.relation(:tasks)
end

def tasks_with_user_and_tags(&block)
  rom.relation(:tasks, &block).with_user.with_tags.as(:task_with_user_and_tags)
end

def tags
  rom.relation(:tags)
end

def users_with_combined_tasks
  @users_with_combined_tasks ||= rom.relation(:users).as(:user_with_combined_tasks)
                                 .combine(rom.relation(:tasks).for_users)
end

def hr
  puts "*" * 80
end

def puts(*)
  super unless VERIFY
end

def run(title, &block)
  if VERIFY
    Verifier.run(&block)
  else
    benchmark(title, &block)
  end
end

def benchmark(title)
  puts "\n"
  puts "=> benchmark: #{title}"
  puts "\n"
  Benchmark.ips do |x|
    x.config(suite: GCSuite.new)
    def x.verify(*); end
    yield x
    x.compare!
  end
  hr
end

class Verifier
  def initialize
    @verify = nil
    yield self
  end

  def self.run(&block)
    new(&block)
  end

  def report(name)
    result = yield
    @verify.call(result) or raise "Expectation failed: #{name}"
  end

  def verify(&block)
    @verify = block
  end
end

DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://localhost/rom')

setup = ROM.setup(:sql, DATABASE_URL)

conn = setup.default.connection

conn.drop_table?(:tags)
conn.drop_table?(:tasks)
conn.drop_table?(:users)

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

conn.create_table :tags do
  primary_key :id
  Integer :task_id
  String :name
end

ActiveRecord::Base.establish_connection(DATABASE_URL)

class ARUser < ActiveRecord::Base
  self.table_name = :users
  has_many :tasks, class_name: 'ARTask', foreign_key: :user_id

  def self.by_name(name)
    select(:id, :name, :email, :age).where(name: name).order(:id)
  end
end

class ARTask < ActiveRecord::Base
  self.table_name = :tasks
  belongs_to :user, class_name: 'ARUser', foreign_key: :user_id
  has_many :tags, class_name: 'ARTag', foreign_key: :task_id

  def self.by_title(title)
    select(:id, :user_id, :title).where(title: title).order(:id)
  end
end

class ARTag < ActiveRecord::Base
  self.table_name = :tags
  belongs_to :task, class_name: 'ARTask', foreign_key: :task_id
end

module Relations
  class Users < ROM::Relation[:sql]
    dataset :users

    one_to_many :tasks, key: :user_id

    def all
      select(:users__id, :users__name, :users__email, :users__age)
        .order(:users__id)
    end

    def by_name(name)
      all.where(name: name).limit(1)
    end

    def with_tasks
      association_left_join(:tasks, select: [:id, :title])
    end
  end

  class Tasks < ROM::Relation[:sql]
    dataset :tasks

    many_to_one :users, key: :user_id
    one_to_many :tags, key: :task_id

    def by_title(title)
      where(title: title)
    end

    def all
      select(:id, :user_id, :title).order(:tasks__id)
    end

    def with_user
      association_left_join(:users, select: [:id, :name, :email, :age])
    end

    def with_tags
      association_left_join(:tags, select: [:id, :task_id, :name])
    end

    def for_users(users)
      all.where(user_id: users.map { |u| u[:id] })
    end
  end
end

module Mappers
  module Users
    class Base < ROM::Mapper
      relation :users

      model name: 'User'

      attribute :id
      attribute :name
      attribute :email
      attribute :age
    end

    class WithCombinedTasks < Base
      model name: 'UserWithCombinedTasks'

      register_as :user_with_combined_tasks

      combine :tasks, on: { id: :user_id } do
        model name: 'CombinedTask'

        attribute :id
        attribute :user_id
        attribute :title
      end
    end

    class WithTasks < Base
      model name: 'UserWithTasks'

      register_as :user_with_tasks

      group :tasks do
        model name: 'UserTask'
        attribute :id, from: :tasks_id
        attribute :title
      end
    end
  end

  module Tasks
    class Base < ROM::Mapper
      relation :tasks

      model name: 'Task'

      attribute :id
      attribute :title
    end

    class WithUser < Base
      register_as :task_with_user

      model name: 'TaskWithUser'

      wrap :user do
        model name: 'TaskUser'

        attribute :id, from: :users_id
        attribute :name
        attribute :email
        attribute :age
      end
    end

    class WithUserAndTags < WithUser
      register_as :task_with_user_and_tags

      model name: 'TaskWithUserAndTags'

      group :tags do
        model name: 'Tag'

        attribute :id, from: :tags_id
        attribute :task_id
        attribute :name, from: :tags_name
      end
    end
  end
end

ROM_ENV = setup.finalize

VERIFY = ENV.fetch('VERIFY') { false }
COUNT = ENV.fetch('COUNT', 1000).to_i

USER_SEED = COUNT.times.map { |i|
  { id:    i + 1,
    name:  "User #{i + 1}",
    email: "email_#{i}@domain.com",
    age:   i*10 }
}

TASK_SEED = USER_SEED.map { |user|
  3.times.map do |i|
    { user_id: user[:id], title: "Task #{i + 1}" }
  end
}.flatten

def seed
  hr

  puts "SEEDING #{USER_SEED.count} users"
  USER_SEED.each do |attributes|
    rom.relations.users.insert(attributes)
  end

  puts "SEEDING #{TASK_SEED.count} tasks"
  TASK_SEED.each do |attributes|
    id = rom.relations.tasks.insert(attributes)
    3.times { |i| rom.relations.tags.insert(task_id: id, name: "Tag #{i}") }
  end

  hr
end

seed

hr
puts "INSERTED #{rom.relations.users.count} users via ROM/Sequel"
puts "INSERTED #{rom.relations.tasks.count} tasks via ROM/Sequel"
puts "INSERTED #{rom.relations.tags.count} tags via ROM/Sequel"
hr
