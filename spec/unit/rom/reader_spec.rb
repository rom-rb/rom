require 'spec_helper'

describe ROM::Reader do
  subject(:reader) { ROM::Reader.new(name, relation, mappers) }

  let(:name) { :users }
  let(:relation) { [jane, joe] }
  let(:jane) { { name: 'Jane' } }
  let(:joe) { { name: 'Joe' } }
  let(:mappers) { ROM::MapperRegistry.new(users: mapper) }
  let(:mapper) { double('mapper', header: []) }

  describe '.build' do
    subject(:reader) do
      ROM::Reader.build(name, relation, mappers, [:all])
    end

    before do
      relation.instance_exec do
        def name
          'users'
        end

        def all(*_args)
          find_all
        end
      end
    end

    it 'sets reader class name' do
      expect(reader.class.name).to eql("ROM::Reader[Users]")
    end

    it 'defines methods from relation' do
      block = proc {}

      user_id = 1

      expect(relation).to receive(:all)
        .with(user_id, &block)
        .and_return([joe])

      expect(mapper).to receive(:call)
        .with([joe])
        .and_return([joe])

      result = reader.all(user_id, &block)

      expect(result.path).to eql('users.all')
      expect(result.to_a).to eql([joe])
    end

    it 'raises error when relation does not respond to the method' do
      expect { reader.not_here }
        .to raise_error(ROM::NoRelationError, /not_here/)
    end

    it 'raises error when relation does not respond to the method with args' do
      expect { reader.find_by_id(1) }
        .to raise_error(ROM::NoRelationError, /find_by_id/)
    end
  end

  describe '#initialize' do
    it 'raises error when mapper cannot be found' do
      expect { ROM::Reader.new(:not_here, relation, mappers) }
        .to raise_error(ROM::MapperMissingError, /not_here/)
    end
  end

  describe '#each' do
    it 'yields mapped tuples from relations' do
      expect(mapper).to receive(:call)
        .with(relation)
        .and_return(relation)

      result = []
      reader.each { |user| result << user }
      expect(result).to eql([jane, joe])
    end
  end

  shared_examples_for 'one and one!' do |method|
    context 'with a single tuple' do
      let(:relation) { [jane] }

      it 'returns a single tuple' do
        expect(mapper).to receive(:call)
          .with(relation)
          .and_return(relation)

        expect(reader.public_send(method)).to eql(jane)
      end
    end

    context 'with more than one tuple' do
      it 'raises an error' do
        expect { reader.public_send(method) }
          .to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end

  describe '#one' do
    it_should_behave_like 'one and one!', :one

    context 'without any tuple' do
      let(:relation) { [] }

      it 'returns nil' do
        expect(mapper).to receive(:call)
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
        expect(mapper).to receive(:call)
          .with(relation)
          .and_return(relation)

        expect { reader.one! }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end

  describe '#to_ary' do
    it 'casts relation to an array with loaded objects' do
      expect(mapper).to receive(:call)
        .with(relation)
        .and_return(relation)

      result = reader.to_ary
      expect(result).to eql(relation)
    end
  end
end
