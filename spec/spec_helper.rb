require 'backports'
require 'backports/basic_object'
require 'rubygems'

begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

require 'veritas'
require 'veritas/optimizer'
require 'veritas-do-adapter'
require 'virtus'
require 'do_postgres'
require 'do_mysql'
require 'do_sqlite3'
require 'randexp'

require 'dm-mapper'

ENV['TZ'] = 'UTC'

# require spec support files and shared behavior
Dir[File.expand_path('../**/shared/**/*.rb', __FILE__)].each { |file| require file }

RSpec.configure do |config|
  # noop for now
end

MAX_RELATION_SIZE = 10
DATABASE_URI      = 'postgres://localhost/test'.freeze
# DATABASE_URI      = 'mysql:/ocalhost/test'.freeze
# DATABASE_URI      = 'sqlite3://tmp/test.db'.freeze
DATABASE_ADAPTER  = Veritas::Adapter::DataObjects.new(DATABASE_URI)

def setup_db
  DataObjects.logger.set_log('log/do.log', :debug)

  connection = DataObjects::Connection.new(DATABASE_URI)

  connection.create_command('DROP TABLE IF EXISTS "users"').execute_non_query
  connection.create_command('DROP TABLE IF EXISTS "addresses"').execute_non_query

  connection.create_command(<<-SQL.gsub(/\s+/, ' ').strip).execute_non_query
    CREATE TABLE "users"
      ( "id"       SERIAL      NOT NULL PRIMARY KEY,
        "username" VARCHAR(50) NOT NULL,
        "age"      SMALLINT    NOT NULL
      )
  SQL

  connection.create_command(<<-SQL.gsub(/\s+/, ' ').strip).execute_non_query
    CREATE TABLE "addresses"
      ( "id"       SERIAL      NOT NULL PRIMARY KEY,
        "user_id"  INTEGER     NOT NULL,
        "street"   VARCHAR(50) NOT NULL,
        "city"     VARCHAR(50) NOT NULL,
        "zipcode"  VARCHAR(10) NOT NULL
      )
  SQL

  connection.close
end

def seed
  connection = DataObjects::Connection.new(DATABASE_URI)
  MAX_RELATION_SIZE.times { |n| insert_user(n + 1, Randgen.name, n*3, connection) }
  connection.close
end

def insert_user(id, name, age, connection = nil)
  connection ||= DataObjects::Connection.new(DATABASE_URI)

  insert_users = connection.create_command(
    'INSERT INTO "users" ("id", "username", "age") VALUES (?, ?, ?)')

  insert_users.execute_non_query(id, name, age)

  connection.close
end

def insert_address(id, user_id, street, city, zipcode, connection = nil)
  connection ||= DataObjects::Connection.new(DATABASE_URI)

  insert_users = connection.create_command(
    'INSERT INTO "addresses" ("id", "user_id", "street", "city", "zipcode") VALUES (?, ?, ?, ?, ?)')

  insert_users.execute_non_query(id, user_id, street, city, zipcode)

  connection.close
end

RSpec.configure do |config|
  config.before(:all) do
    Object.send(:remove_const, :User)    if defined?(User)
    Object.send(:remove_const, :Address) if defined?(Address)
  end
end
