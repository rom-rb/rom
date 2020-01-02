require 'rom/relation'

RSpec.describe ROM::Relation, '#call' do
  subject(:relation) do
    relation_class.new(data, **options)
  end

  let(:options) do
    {}
  end

  context 'without read types in schema' do
    let(:relation_class) do
      Class.new(ROM::Relation[:memory]) do
        schema do
          attribute :id, ROM::Types::Integer
          attribute :name, ROM::Types::String
        end
      end
    end

    let(:data) do
      ROM::Memory::Dataset.new([{ id: '1', name: 'Jane' }, { id: '2', name: 'John' }])
    end

    it 'has noop output_schema' do
      expect(relation.output_schema).to be(ROM::Relation::NOOP_OUTPUT_SCHEMA)
    end

    it 'returns loaded relation with data' do
      expect(relation.call.collection)
        .to eql(data.to_a)
    end
  end

  context 'with read types in schema' do
    let(:relation_class) do
      Class.new(ROM::Relation[:memory]) do
        schema do
          attribute :id, ROM::Types::String, read: ROM::Types::Coercible::Integer
          attribute :name, ROM::Types::String
        end
      end
    end

    let(:data) do
      [{ id: '1', name: 'Jane' }, { id: '2', name: 'John' }]
    end

    it 'returns loaded relation with coerced data' do
      expect(relation.call.collection)
        .to eql([{ id: 1, name: 'Jane' }, { id: 2, name: 'John' }])
    end
  end

  describe 'auto-struct' do
    let(:relation_class) do
      Class.new(ROM::Relation[:memory]) do
        schema(:users) do
          attribute :id, ROM::Types::Integer
          attribute :name, ROM::Types::String
        end
      end
    end

    let(:options) do
      { auto_struct: true }
    end

    let(:data) do
      ROM::Memory::Dataset.new([{ id: 1, name: 'Jane' }, { id: 2, name: 'John' }])
    end

    it 'automatically maps to structs' do
      result = relation.call.to_a

      expect(result[0].id).to be(1)
      expect(result[0].name).to eql('Jane')

      expect(result[1].id).to be(2)
      expect(result[1].name).to eql('John')
    end

    it 'supports aliasing' do
      result = relation.rename(id: :user_id, name: :user_name).call.to_a

      expect(result[0].user_id).to be(1)
      expect(result[0].user_name).to eql('Jane')

      expect(result[1].user_id).to be(2)
      expect(result[1].user_name).to eql('John')
    end
  end
end
