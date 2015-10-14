require 'rom/memory'

RSpec.describe ROM::Plugins::Relation::View do
  subject(:relation) { relation_class.new([]) }

  let(:relation_class) do
    Class.new(ROM::Memory::Relation) do
      use :view

      view(:base, [:id, :name]) do
        self
      end

      view(:ids, [:id]) do
        self
      end
    end
  end

  describe '#attributes' do
    it 'returns base view attributes by default' do
      expect(relation.attributes).to eql([:id, :name])
    end

    it 'returns attributes for a configured view' do
      expect(relation.ids.attributes).to eql([:id])
    end
  end
end
