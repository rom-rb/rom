# frozen_string_literal: true

require "sequel"

RSpec.shared_context "changeset / db_uri" do
  let(:base_db_uri) do
    ENV.fetch("BASE_DB_URI", "postgres@localhost/rom")
  end

  let(:db_uri) do
    defined?(JRUBY_VERSION) ? "jdbc:postgresql://#{base_db_uri}" : "postgres://#{base_db_uri}"
  end
end

RSpec.shared_context "changeset / database setup" do
  include_context "changeset / db_uri"

  let(:configuration) do
    ROM::Configuration.new(:sql, db_uri) do |config|
      config.plugin(:sql, relation: :auto_restrictions)
    end
  end

  let(:conn) { configuration.gateways[:default].connection }

  let(:rom) { ROM.container(configuration) }

  let(:logger) do
    Logger.new(File.open("./log/test.log", "a"))
  end

  before :all do
    Sequel.database_timezone = :utc
    Sequel.application_timezone = :utc
  end

  before do
    conn.loggers << logger
  end
end

RSpec.shared_context "changeset / database" do
  include_context "changeset / database setup"

  before do
    %i[tags tasks books posts_labels posts users labels
       reactions messages].each { |table| conn.drop_table?(table) }

    conn.create_table :users do
      primary_key :id
      column :name, String
    end

    conn.create_table :books do
      primary_key :id
      foreign_key :author_id, :users, on_delete: :cascade
      column :title, String
      column :created_at, Time
      column :updated_at, Time
    end

    conn.create_table :tasks do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      column :title, String
    end

    conn.create_table :tags do
      primary_key :id
      foreign_key :task_id, :tasks, null: false, on_delete: :cascade
      column :name, String
    end

    conn.create_table :labels do
      primary_key :id
      column :name, String
    end

    conn.create_table :posts do
      primary_key :id
      foreign_key :author_id, :users, null: false, on_delete: :cascade
      column :title, String, null: false
      column :body, String
    end

    conn.create_table :posts_labels do
      foreign_key :post_id, :posts, null: false, on_delete: :cascade
      foreign_key :label_id, :labels, null: false, on_delete: :cascade
      primary_key %i[post_id label_id]
    end

    conn.create_table :messages do
      primary_key :message_id
      column :author, String
      column :body, String
    end

    conn.create_table :reactions do
      primary_key :reaction_id
      foreign_key :message_id, :messages, null: false
      column :author, String
    end
  end

  after do
    rom.disconnect
  end
end
