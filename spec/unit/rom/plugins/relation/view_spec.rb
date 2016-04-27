require 'rom'
require 'rom/memory'
require 'rom/plugins/relation/view'

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

      view(:names, [:name]) do |id|
        self
      end
    end
  end

  describe '#attributes' do
    it 'returns base view attributes by default' do
      expect(relation.attributes).to eql([:id, :name])
    end

    it 'returns attributes for a view' do
      expect(relation.ids.attributes).to eql([:id])
    end

    it 'returns attributes for a view with args' do
      expect(relation.names(1).attributes).to eql([:name])
    end

    it 'returns attributes for a curried view' do
      expect(relation.names.attributes).to eql([:name])
    end

    it 'returns correct arity for a curried view' do
      expect(relation.names.arity).to be(1)
    end

    it 'returns explicitly set attributes' do
      expect(relation.with(attributes: [:foo, :bar]).attributes).to eql([:foo, :bar])
    end
  end
end
