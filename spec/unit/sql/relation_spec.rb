RSpec.describe 'SQL Relation extensions' do
  include_context 'database'

  describe '.view' do
    it 'defines a header with a view method' do
      setup.relation(:users) do
        view(:by_id, [:name]) do |name|
          where(name: name).select(:name)
        end
      end

      users = rom.relation(:users)

      expect(users.columns).to eql([:id, :name])

      expect(users.by_id.columns).to eql([:name])
      expect(users.by_id(1).columns).to eql([:name])
    end
  end
end
