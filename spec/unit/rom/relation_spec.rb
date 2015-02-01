require 'spec_helper'
require 'rom/memory/dataset'

describe ROM::Relation do
  subject(:relation) { Class.new(ROM::Relation).new(dataset) }

  let(:dataset) { ROM::Memory::Dataset.new([jane, joe]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  describe '.[]' do
    before do
      module TestAdapter
        class Relation < ROM::Relation
          def test_relation?
            true
          end
        end
      end

      ROM.register_adapter(:test, TestAdapter)
    end

    it 'returns relation subclass from the registered adapter' do
      relation = ROM::Relation[:test].new([])

      expect(relation).to be_test_relation
    end
  end

  describe '#name' do
    context 'missing base_name' do
      context 'with Relation inside module' do
        before do
          module Test
            class Relation < ROM::Relation; end
          end
        end

        it 'returns name based on module and class' do
          relation = Test::Relation.new([])

          expect(relation.name).to eq(:test_relation)
        end
      end

      context 'with Relation without module' do
        before do
          class Relation < ROM::Relation; end
        end

        it 'returns name based only on class' do
          relation = Relation.new([])

          expect(relation.name).to eq(:relation)
        end
      end
    end

    context 'manualy set base_name' do
      before do
        module TestAdapter
          class Relation < ROM::Relation
            base_name :foo_bar
          end
        end
      end

      it 'returns name based on base_name' do
        relation = TestAdapter::Relation.new([])

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

  describe "#to_a" do
    it "materializes relation to an array" do
      expect(relation.to_a).to eql([jane, joe])
    end
  end
end
