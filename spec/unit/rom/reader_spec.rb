require 'spec_helper'

describe ROM::Reader do
  subject(:reader) { ROM::Reader.new(name, relation, mappers) }

  let(:name) { :users }
  let(:relation) { [jane, joe] }
  let(:jane) { { name: 'Jane' } }
  let(:joe) { { name: 'Joe' } }
  let(:mappers) { { users: mapper } }
  let(:mapper) { double('mapper', header: []) }

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

  describe '#method_missing' do
    before do
      relation.instance_exec do
        def all(*args)
          find_all
        end
      end
    end

    it 'forwards to relation and wraps the response and maintains the path' do
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
      expect { reader.not_here }.
        to raise_error(ROM::NoRelationError, /not_here/)
    end
  end
end
