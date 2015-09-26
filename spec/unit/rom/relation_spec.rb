require 'spec_helper'
require 'rom/memory'

describe ROM::Relation do
  subject(:relation) { Class.new(ROM::Relation).new(dataset) }

  let(:dataset) { ROM::Memory::Dataset.new([jane, joe]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  describe '.[]' do
    before do
      module Test::TestAdapter
        class Relation < ROM::Relation
          adapter :test

          def test_relation?
            true
          end
        end
      end

      module Test::BrokenAdapter
        class Relation < ROM::Relation
          def test_relation?
            true
          end
        end
      end

      ROM.register_adapter(:test, Test::TestAdapter)
      ROM.register_adapter(:broken, Test::BrokenAdapter)
    end

    it 'returns relation subclass from the registered adapter' do
      subclass = Class.new(ROM::Relation[:test])

      relation = subclass.new([])

      expect(relation).to be_test_relation
    end

    it 'raises error when adapter relation has no identifier' do
      expect {
        Class.new(ROM::Relation[:broken])
      }.to raise_error(ROM::MissingAdapterIdentifierError, /Test::BrokenAdapter::Relation/)
    end
  end

  describe ".register_as" do
    it "defaults to dataset with a generated class" do
      rel = Class.new(ROM::Relation[:memory]) { dataset :users }
      expect(rel.register_as).to eq(:users)
      rel.register_as(:guests)
      expect(rel.register_as).to eq(:guests)
    end

    it "defaults to dataset with a defined class that has dataset inferred" do
      class Test::Users < ROM::Relation[:memory]; end
      expect(Test::Users.register_as).to eq(:test_users)
    end

    it "defaults to dataset with a defined class that has dataset set manually" do
      class Test::Users < ROM::Relation[:memory]
        dataset :guests
      end
      expect(Test::Users.register_as).to eq(:guests)
    end

    it "defaults to :name for descendant classes" do
      class Test::SuperUsers < ROM::Relation[:memory]
        dataset :users
      end

      class Test::DescendantUsers < Test::SuperUsers;end

      expect(Test::DescendantUsers.register_as).to eq(:test_descendant_users)
    end

    it "sets custom value for super and descendant classes" do
      class Test::SuperUsers < ROM::Relation[:memory]
        register_as :users
      end

      class Test::DescendantUsers < Test::SuperUsers
        register_as :descendant_users
      end

      expect(Test::SuperUsers.register_as).to eq(:users)
      expect(Test::DescendantUsers.register_as).to eq(:descendant_users)
    end
  end

  describe '#name' do
    context 'missing dataset' do
      context 'with Relation inside module' do
        before do
          module Test::Test
            class SuperRelation < ROM::Relation[:memory]; end
          end
        end

        it 'returns name based on module and class' do
          relation = Test::Test::SuperRelation.new([])

          expect(relation.name).to eq(:test_test_super_relation)
        end
      end

      context 'with Relation without module' do
        before do
          class Test::SuperRelation < ROM::Relation[:memory]; end
        end

        it 'returns name based only on class' do
          relation = Test::SuperRelation.new([])

          expect(relation.name).to eq(:test_super_relation)
        end
      end

      context 'with a descendant relation' do
        before do
          class Test::SuperRelation < ROM::Relation[:memory]; end
          class Test::DescendantRelation < Test::SuperRelation; end
        end

        it 'inherits :name from the super relation' do
          relation = Test::DescendantRelation.new([])

          expect(relation.name).to eql(:test_super_relation)
        end
      end
    end

    context 'manualy set dataset' do
      before do
        module Test::TestAdapter
          class Relation < ROM::Relation[:memory]
            dataset :foo_bar
          end
        end
      end

      it 'returns name based on dataset' do
        relation = Test::TestAdapter::Relation.new([])

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

  describe "#curried?" do
    it "returns false" do
      expect(relation.curried?).to be(false)
    end
  end
end
