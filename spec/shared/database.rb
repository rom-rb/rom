RSpec.shared_context 'database' do
  let(:configuration) { ROM::Configuration.new(:sql, uri) }
  let(:conn) { configuration.gateways[:default].connection }
  let(:rom) { ROM.container(configuration) }
  let(:uri) do
    if defined? JRUBY_VERSION
      'jdbc:postgresql://localhost/rom_repository'
    else
      'postgres://localhost/rom_repository'
    end
  end

  before do
    conn.loggers << LOGGER

    [:tags, :tasks, :posts, :users, :posts_labels, :labels, :messages].each { |table| conn.drop_table?(table) }

    conn.create_table :users do
      primary_key :id
      column :name, String
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
      column :title, String
      column :body, String
    end

    conn.create_table :posts_labels do
      foreign_key :post_id, :labels, null: false, on_delete: :cascade
      foreign_key :label_id, :labels, null: false, on_delete: :cascade
      primary_key [:post_id, :label_id]
    end

    conn.create_table :messages do
      primary_key :id
      column :author, String
      column :body, String
    end
  end
end
