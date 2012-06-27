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

ROOT = File.expand_path('../..', __FILE__)

CONFIG = YAML.load_file("#{ROOT}/config/database.yml")

CONFIG.each do |name, uri|
  DataMapper.setup(name, uri)
end

DATABASE_ADAPTER = DataMapper.adapters[:postgres]

MAX_RELATION_SIZE = 10

def setup_db
  DataObjects.logger.set_log('log/do.log', :debug)

  connection = DataObjects::Connection.new(CONFIG['postgres'])

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
  connection = DataObjects::Connection.new(CONFIG['postgres'])
  MAX_RELATION_SIZE.times { |n| insert_user(n + 1, Randgen.name, n*3, connection) }
  connection.close
end

def insert_user(id, name, age, connection = nil)
  connection ||= DataObjects::Connection.new(CONFIG['postgres'])

  insert_users = connection.create_command(
    'INSERT INTO "users" ("id", "username", "age") VALUES (?, ?, ?)')

  insert_users.execute_non_query(id, name, age)

  connection.close
end

def insert_address(id, user_id, street, city, zipcode, connection = nil)
  connection ||= DataObjects::Connection.new(CONFIG['postgres'])

  insert_users = connection.create_command(
    'INSERT INTO "addresses" ("id", "user_id", "street", "city", "zipcode") VALUES (?, ?, ?, ?, ?)')

  insert_users.execute_non_query(id, user_id, street, city, zipcode)

  connection.close
end

# require spec support files and shared behavior
Dir[File.expand_path('../**/shared/**/*.rb', __FILE__)].each { |file| require file }

RSpec.configure do |config|
  config.before(:all) do
    Object.send(:remove_const, :User)    if defined?(User)
    Object.send(:remove_const, :Address) if defined?(Address)
  end
end
