shared_context 'database' do
  let(:setup) { ROM.setup(:sql, 'postgres://localhost/rom') }
  let(:conn) { setup.gateways[:default].connection }
  let(:rom) { setup.finalize }

  before do
    conn.drop_table?(:users)

    conn.create_table :users do
      primary_key :id
      column :name, String
    end
  end
end
