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

  shared_examples_for 'one and one!' do |method|
    context 'with a single tuple' do
      let(:relation) { [jane] }

      it 'returns a single tuple' do
        expect(mapper).to receive(:process)
          .with(relation)
          .and_return(relation)

        expect(reader.public_send(method)).to eql(jane)
      end
    end

    context 'with more than one tuple' do
      it 'raises an error' do
        expect { reader.public_send(method) }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end

  describe '#one' do
    it_should_behave_like 'one and one!', :one

    context 'without any tuple' do
      let(:relation) { [] }

      it 'returns nil' do
        expect(mapper).to receive(:process)
          .with(relation)
          .and_return(relation)

        expect(reader.one).to be_nil
      end
    end
  end

  describe '#one!' do
    it_should_behave_like 'one and one!', :one!

    context 'without any tuple' do
      let(:relation) { [] }

      it 'raises an error' do
        expect(mapper).to receive(:process)
          .with(relation)
          .and_return(relation)

        expect { reader.one! }.to raise_error(ROM::TupleCountMismatchError)
      end
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
