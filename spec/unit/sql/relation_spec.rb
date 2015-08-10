RSpec.describe 'SQL Relation extensions' do
  include_context 'database'

  shared_context 'valid view' do
    let(:users) { rom.relation(:users) }

    it 'has valid column names' do
      expect(users.attributes).to eql([:id, :name])

      expect(users.by_id.attributes).to eql([:name])
      expect(users.by_id(1).attributes).to eql([:name])
    end
  end

  describe '.view' do
    context 'using short syntax' do
      before do
        setup.relation(:users) do
          view(:by_id, [:name]) do |name|
            where(name: name).select(:name)
          end
        end
      end

      include_context 'valid view'
    end

    context 'with multi-block syntax' do
      before do
        setup.relation(:users) do
          view(:by_id) do
            header [:name]

            relation do |name|
              where(name: name).select(:name)
            end
          end
        end
      end

      include_context 'valid view'
    end
  end
end
