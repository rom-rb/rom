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
      ROM::ReaderBuilder.build(name, relation, mappers, [:all])
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

    it 'raises error when relation does not respond to the method with args' do
      expect { reader.find_by_id(1) }
        .to raise_error(ROM::NoRelationError, /find_by_id/)
    end
  end
end
