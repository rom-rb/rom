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
        .to raise_error(ROM::Reader::MapperMissingError, /not_here/)
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

  describe '.build' do
    subject(:reader) { ROM::Reader.build(name, relation, mappers, [:all]) }

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

      expect(relation).to receive(:all)
        .with(1, &block)
        .and_return([joe])

      expect(mapper).to receive(:process)
        .with([joe])
        .and_yield(joe)

      result = reader.all(1, &block)

      expect(result.path).to eql('users.all')
      expect(result.to_a).to eql([joe])
    end

    it 'raises error when relation does not respond to the method' do
      expect { reader.not_here }
        .to raise_error(ROM::NoRelationError, /not_here/)
    end
  end
end
