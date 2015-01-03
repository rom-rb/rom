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

def tags
  rom.read(:tags)
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

DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://localhost/rom')

setup = ROM.setup(pg: DATABASE_URL)

conn = setup.pg.connection

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
end

class ARTag < ActiveRecord::Base
  self.table_name = :tags
  belongs_to :task, class_name: 'ARTask', foreign_key: :task_id
end

setup.relation(:users) do
  one_to_many :tasks, key: :user_id

  def all
    select(:id, :name, :email, :age).order(:users__id)
  end

  def by_name(name)
    all.where(name: name).limit(1)
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
  one_to_many :tags, key: :task_id

  def all
    select(:id, :user_id, :title).order(:tasks__id)
  end

  def with_user
    association_left_join(:users, select: [:id, :name, :email, :age])
  end

  def with_tags
    association_left_join(:tags, select: [:id, :task_id, :name])
  end
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

    group :tags do
      model name: 'Tag'

      attribute :id, from: :tags_id
      attribute :task_id
      attribute :name, from: :tags_name
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
  hr

  puts "SEEDING #{USER_SEED.count} users"
  USER_SEED.each do |attributes|
    rom.schema.users.insert(attributes)
  end

  puts "SEEDING #{TASK_SEED.count} tasks"
  TASK_SEED.each do |attributes|
    id = rom.schema.tasks.insert(attributes)
    3.times { |i| rom.schema.tags.insert(task_id: id, name: "Tag #{i}") }
  end

  hr
end

seed

hr
puts "INSERTED #{rom.schema.users.count} users via ROM/Sequel"
puts "INSERTED #{rom.schema.tasks.count} tasks via ROM/Sequel"
puts "INSERTED #{rom.schema.tags.count} tags via ROM/Sequel"
hr
