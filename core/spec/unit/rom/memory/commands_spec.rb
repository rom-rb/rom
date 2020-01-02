# frozen_string_literal: true

require 'spec_helper'
require 'rom/memory'

RSpec.describe ROM::Memory::Commands do
  let(:relation) do
    Class.new(ROM::Relation[:memory]) do
      schema do
        attribute :id, ROM::Memory::Types::Integer
        attribute :name, ROM::Memory::Types::String
      end
    end.new(ROM::Memory::Dataset.new([]))
  end

  describe 'Create' do
    subject(:command) { ROM::Commands::Create[:memory].build(relation) }

    describe '#call' do
      it 'uses default input handler' do
        result = command.call([id: 1, name: 'Jane', haha: 'oops'])

        expect(result).to eql([{ id: 1, name: 'Jane' }])
      end
    end
  end

  describe 'Update' do
    subject(:command) { ROM::Commands::Update[:memory].build(relation) }

    before do
      relation.insert(id: 1, name: 'Jane')
    end

    describe '#call' do
      it 'uses default input handler' do
        result = command
          .new(relation.restrict(id: 1))
          .call(name: 'Jane Doe', haha: 'oops')

        expect(result).to eql([{ id: 1, name: 'Jane Doe' }])
      end
    end
  end
end
