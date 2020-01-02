# frozen_string_literal: true

require 'bundler'

Bundler.require

require 'benchmark/ips'
require 'rom-sql'
require 'rom-repository'
require 'active_record'
require 'logger'

begin
  require 'byebug'
rescue LoadError
end

require_relative 'gc_suite'

SEED = ENV['SEED'] == 'true'

def rom
  ROM_ENV
end

def relations
  rom.relations
end

def posts
  @posts ||= rom.relations[:posts].with(auto_map: true, auto_struct: true)
end

def users
  @users ||= rom.relations[:users].with(auto_map: true, auto_struct: true)
end

def users_hashes
  @users_hashes ||= rom.relations[:users].with(auto_map: true)
end

def tasks
  @tasks ||= rom.relations[:tasks].with(auto_map: true, auto_struct: true)
end

def hr
  puts '*' * 80
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

DATABASE_URL = ENV.fetch('DATABASE_URL', RUBY_ENGINE == 'jruby' ? 'jdbc:postgresql://localhost/rom' : 'postgres://localhost/rom')

setup = ROM::Configuration.new(:sql, DATABASE_URL)

setup.default.use_logger(Logger.new('./log/bench_rom.log'))
conn = setup.default.connection

if SEED
  conn.drop_table?(:users_posts)
  conn.drop_table?(:tags)
  conn.drop_table?(:tasks)
  conn.drop_table?(:users)
  conn.drop_table?(:posts)

  conn.create_table :users do
    primary_key :id
    column :name, String, null: false
    column :email, String, null: false
    column :age, Integer, null: false
  end

  conn.create_table :posts do
    primary_key :id
    column :title, String, null: false
  end

  conn.create_table :users_posts do
    primary_key :id
    foreign_key :user_id, :users, null: false
    foreign_key :post_id, :posts, null: false
  end

  conn.create_table :tasks do
    primary_key :id
    foreign_key :user_id, :users, null: false
    column :title, String, null: false
  end

  conn.create_table :tags do
    primary_key :id
    foreign_key :task_id, :tasks, null: false
    column :name, String, null: false
  end
end

if RUBY_ENGINE == 'jruby'
  ActiveRecord::Base.establish_connection(url: DATABASE_URL, adapter: 'postgresql')
else
  ActiveRecord::Base.establish_connection(DATABASE_URL)
end

ActiveRecord::Base.logger = Logger.new('./log/bench_ar.log')

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

class ARPost < ActiveRecord::Base
  self.table_name = :posts
  has_many :users_posts, class_name: 'ARUserPost', foreign_key: 'post_id'
  has_many :users, through: :users_posts, class_name: 'ARUser', foreign_key: 'user_id'
end

class ARUserPost < ActiveRecord::Base
  self.table_name = :users_posts
  belongs_to :user, class_name: 'ARUser', foreign_key: 'user_id'
  belongs_to :post, class_name: 'ARPost', foreign_key: 'post_id'
end

module Relations
  class Users < ROM::Relation[:sql]
    schema(:users, infer: true) do
      associations do
        has_many :tasks
        has_many :users_posts
        has_many :posts, through: :users_posts
      end
    end

    def by_name(name)
      where(name: name).limit(1)
    end
  end

  class Tasks < ROM::Relation[:sql]
    schema(:tasks, infer: true) do
      associations do
        belongs_to :user
        has_many :tags
      end
    end

    def by_title(title)
      where(title: title)
    end
  end

  class UsersPosts < ROM::Relation[:sql]
    schema(:users_posts, infer: true) do
      associations do
        belongs_to :users
        belongs_to :posts
      end
    end
  end

  class Posts < ROM::Relation[:sql]
    schema(:posts, infer: true) do
      associations do
        has_many :users_posts
        has_many :users, through: :users_posts
      end
    end
  end

  class Tags < ROM::Relation[:sql]
    schema(:tags, infer: true) do
      associations do
        belongs_to :task
      end
    end
  end
end

setup.register_relation(Relations::Users)
setup.register_relation(Relations::Tasks)
setup.register_relation(Relations::Tags)
setup.register_relation(Relations::Posts)
setup.register_relation(Relations::UsersPosts)

ROM_ENV = ROM.container(setup)

VERIFY = ENV.fetch('VERIFY') { false }
COUNT = ENV.fetch('COUNT', 1000).to_i

USER_SEED = COUNT.times.map { |i|
  { id: i + 1,
    name: "User #{i + 1}",
    email: "email_#{i}@domain.com",
    age: i * 10 }
}

TASK_SEED = USER_SEED.map { |user|
  3.times.map do |i|
    { user_id: user[:id], title: "Task #{i + 1}" }
  end
}.flatten

POST_SEED = 3000.times.map { |i|
  { id: i + 1, title: "Post #{i + 1}" }
}

USER_POST_SEED = POST_SEED.map { |post|
  3.times.map do |_i|
    { post_id: post[:id], user_id: USER_SEED.pluck(:id).sample }
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

  puts "SEEDING #{POST_SEED.count} posts"
  POST_SEED.each do |attributes|
    rom.relations.posts.insert(attributes)
  end

  puts "SEEDING #{USER_POST_SEED.count} user posts"
  USER_POST_SEED.each do |attributes|
    rom.relations.users_posts.insert(attributes)
  end

  hr
end

if SEED
  seed

  hr
  puts "INSERTED #{rom.relations.users.count} users via ROM/Sequel"
  puts "INSERTED #{rom.relations.tasks.count} tasks via ROM/Sequel"
  puts "INSERTED #{rom.relations.tags.count} tags via ROM/Sequel"
  hr
end
