shared_context 'database' do
  let(:setup) { ROM.setup(:sql, 'postgres://localhost/rom') }
  let(:conn) { setup.gateways[:default].connection }
  let(:rom) { setup.finalize }

  before do
    [:tasks, :users].each { |table| conn.drop_table?(table) }

    conn.create_table :users do
      primary_key :id
      column :name, String
    end

    conn.create_table :tasks do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      column :title, String
    end
  end
end
