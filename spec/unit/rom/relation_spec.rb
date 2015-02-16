require 'spec_helper'
require 'rom/memory/dataset'

describe ROM::Relation do
  subject(:relation) { Class.new(ROM::Relation).new(dataset) }

  let(:dataset) { ROM::Memory::Dataset.new([jane, joe]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  describe '.[]' do
    before do
      module ROMSpec::TestAdapter
        class Relation < ROM::Relation
          def test_relation?
            true
          end
        end
      end

      ROM.register_adapter(:test, ROMSpec::TestAdapter)
    end

    it 'returns relation subclass from the registered adapter' do
      relation = ROM::Relation[:test].new([])

      expect(relation).to be_test_relation
    end
  end

  describe '#name' do
    before { ROM.setup(:memory) }

    context 'missing dataset' do
      context 'with Relation inside module' do
        before do
          module ROMSpec::Test
            class SuperRelation < ROM::Relation[:memory]; end
          end
        end

        it 'returns name based on module and class' do
          relation = ROMSpec::Test::SuperRelation.new([])

          expect(relation.name).to eq(:rom_spec_test_super_relation)
        end
      end

      context 'with Relation without module' do
        before do
          class ROMSpec::SuperRelation < ROM::Relation[:memory]; end
        end

        it 'returns name based only on class' do
          relation = ROMSpec::SuperRelation.new([])

          expect(relation.name).to eq(:rom_spec_super_relation)
        end
      end
    end

    context 'manualy set dataset' do
      before do
        module ROMSpec::TestAdapter
          class Relation < ROM::Relation[:memory]
            dataset :foo_bar
          end
        end
      end

      it 'returns name based on dataset' do
        relation = ROMSpec::TestAdapter::Relation.new([])

        expect(relation.name).to eq(:foo_bar)
      end
    end
  end

  describe "#each" do
    it "yields all objects" do
      result = []

      relation.each do |user|
        result << user
      end

      expect(result).to eql([jane, joe])
    end

    it "returns an enumerator if block is not provided" do
      expect(relation.each).to be_instance_of(Enumerator)
    end
  end

  describe ".register_as" do
    before { ROM.setup(:memory) }

    it "defaults to dataset with a generated class" do
      rel = Class.new(ROM::Relation[:memory]) { dataset :users }
      expect(rel.register_as).to eq(:users)
      rel.register_as(:guests)
      expect(rel.register_as).to eq(:guests)
    end

    it "defaults to dataset with a defined class that has dataset inferred" do
      class ROMSpec::Users < ROM::Relation[:memory]; end
      expect(ROMSpec::Users.register_as).to eq(:rom_spec_users)
    end

    it "defaults to dataset with a defined class that has dataset set manually" do
      class ROMSpec::Users < ROM::Relation[:memory]
        dataset :guests
      end
      expect(ROMSpec::Users.register_as).to eq(:guests)
    end
  end

  describe "#to_a" do
    it "materializes relation to an array" do
      expect(relation.to_a).to eql([jane, joe])
    end
  end
end
