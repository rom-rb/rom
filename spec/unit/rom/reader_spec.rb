require 'spec_helper'

describe ROM::Reader do
  subject(:reader) { ROM::Reader.new(name, relation, mappers) }

  let(:name) { :users }
  let(:relation) { [jane, joe] }
  let(:jane) { { name: 'Jane' } }
  let(:joe) { { name: 'Joe' } }
  let(:mappers) { ROM::MapperRegistry.new(users: mapper) }
  let(:mapper) { double('mapper', header: []) }

  describe '#initialize' do
    it 'raises error when mapper cannot be found' do
      expect { ROM::Reader.new(:not_here, relation, mappers) }
        .to raise_error(ROM::MapperMissingError, /not_here/)
    end
  end

  describe '#each' do
    it 'yields mapped tuples from relations' do
      expect(mapper).to receive(:process)
        .with(relation)
        .and_yield(jane).and_yield(joe)

      result = []
      reader.each { |user| result << user }
      expect(result).to eql([jane, joe])
    end
  end

  describe '#to_ary' do
    it 'casts relation to an array with loaded objects' do
      expect(mapper).to receive(:process)
        .with(relation)
        .and_yield(jane).and_yield(joe)

      result = reader.to_ary
      expect(result).to eql(relation)
    end
  end
end
