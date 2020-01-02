# frozen_string_literal: true

require 'rom/relation'

RSpec.describe ROM::Relation, '.relation_name' do
  context 'when schema is defined' do
    subject(:relation_class) do
      Class.new(ROM::Relation) do
        schema(:users) do
          attribute :name, ROM::Types::String
        end
      end
    end

    it 'returns relation name configured by schema' do
      expect(relation_class.relation_name).to eql(ROM::Relation::Name[:users])
    end
  end

  context 'when schema is not defined' do
    subject(:relation_class) do
      Class.new(ROM::Relation)
    end

    it 'raises error' do
      expect { relation_class.relation_name }.to raise_error(ROM::MissingSchemaError)
    end
  end
end
