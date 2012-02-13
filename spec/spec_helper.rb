require 'backports'
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

require 'data_mapper/mapper'
require 'data_mapper/veritas_mapper'

require 'do_postgres'
require 'randexp'

ENV['TZ'] = 'UTC'

# require spec support files and shared behavior
Dir[File.expand_path('../**/shared/**/*.rb', __FILE__)].each { |file| require file }

RSpec.configure do |config|
  # noop for now
end

MAX_RELATION_SIZE = 10
DATABASE_URI      = 'postgres://localhost/test'.freeze
DATABASE_ADAPTER  = Veritas::Adapter::DataObjects.new(DATABASE_URI)

def setup_db
  DataObjects.logger.set_log('log/do.log', :debug)

  connection = DataObjects::Connection.new(DATABASE_URI)

  connection.create_command('DROP TABLE IF EXISTS "users"').execute_non_query

  connection.create_command(<<-SQL.gsub(/\s+/, ' ').strip).execute_non_query
    CREATE TABLE "users"
      ( "id"   SERIAL      NOT NULL PRIMARY KEY
      , "username" VARCHAR(50) NOT NULL
      )
  SQL

  connection.close
end

def seed
  connection = DataObjects::Connection.new(DATABASE_URI)
  MAX_RELATION_SIZE.times { |n| insert_user(n + 1, Randgen.name, connection) }
  connection.close
end

def insert_user(id, name, connection = nil)
  connection ||= DataObjects::Connection.new(DATABASE_URI)

  insert_users = connection.create_command(
    'INSERT INTO "users" ("id", "username") VALUES (?, ?)')

  insert_users.execute_non_query(id, name)

  connection.close
end
