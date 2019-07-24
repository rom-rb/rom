RSpec.shared_context 'database setup' do
  let(:configuration) { ROM::Configuration.new(:sql, DB_URI) }

  let(:conn) { configuration.gateways[:default].connection }

  let(:rom) { ROM.container(configuration) }

  before :all do
    Sequel.database_timezone = :utc
    Sequel.application_timezone = :utc
  end

  before do
    conn.loggers << LOGGER
  end
end

RSpec.shared_context 'database' do
  include_context 'database setup'

  before do
    [:tags, :tasks, :books, :posts_labels, :posts, :users, :labels,
     :reactions, :messages].each { |table| conn.drop_table?(table) }

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
      primary_key [:post_id, :label_id]
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
