require 'rom/memory'

RSpec.describe ROM::Relation do
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

  describe ".dataset" do
    it 'allows setting dataset name' do
      rel_class = Class.new(ROM::Relation[:memory]) { dataset :users }

      expect(rel_class.dataset).to be(:users)
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

    it "defaults to :dataset of parent class" do
      class Test::SuperUsers < ROM::Relation[:memory]
        dataset :users
      end

      class Test::DescendantUsers < Test::SuperUsers; end

      expect(Test::DescendantUsers.register_as).to be(:users)
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

    it "sets provided value overriding inherited value" do
      module Test
        class BaseRelation < ROM::Relation[:memory]
        end

        class UsersRelation < BaseRelation
          register_as :users
          dataset :users
        end
      end

      expect(Test::UsersRelation.register_as).to be(:users)
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

          expect(relation.name).to eql(ROM::Relation::Name.new(:test_test_super_relation))
        end
      end

      context 'with Relation without module' do
        before do
          class Test::SuperRelation < ROM::Relation[:memory]; end
        end

        it 'returns name based only on class' do
          relation = Test::SuperRelation.new([])

          expect(relation.name).to eql(ROM::Relation::Name.new(:test_super_relation))
        end
      end

      context 'with a descendant relation' do
        before do
          class Test::SuperRelation < ROM::Relation[:memory]; end
          class Test::DescendantRelation < Test::SuperRelation; end
        end

        it 'inherits :name from the super relation' do
          relation = Test::DescendantRelation.new([])

          expect(relation.name).to eql(ROM::Relation::Name.new(:test_super_relation))
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

        expect(relation.name).to eql(ROM::Relation::Name.new(:foo_bar))
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

  describe "#with" do
    it "returns a new instance with the original dataset and given custom options" do
      relation = Class.new(ROM::Relation) { option :custom }.new([], custom: true)

      custom_opts = { mappers: "Custom Mapper Registry" }
      new_relation = relation.with(custom_opts).with(custom: true)

      expect(new_relation.dataset).to be(relation.dataset)
      expect(new_relation.options).to include(custom_opts.merge(custom: true))
    end
  end

  describe '#graph?' do
    it 'returns false' do
      expect(relation.graph?).to be(false)
    end

    it 'returns false when curried' do
      relation = Class.new(ROM::Relation[:memory]) { def by_name(_); self; end }.new([])
      expect(relation.by_name.graph?).to be(false)
    end
  end

  describe '#schema' do
    it 'returns an empty schema by default' do
      relation = Class.new(ROM::Relation) {
        def self.name
          'Test::SomeRelation'
        end
      }.new([])

      expect(relation.schema).to be_empty
      expect(relation.schema.inferrer).to be(ROM::Schema::DEFAULT_INFERRER)
      expect(relation.schema.name).to be(:test_some_relation)
      expect(relation.schema?).to be(false)
    end
  end

  describe '#input_schema' do
    it 'returns a schema hash type' do
      relation = Class.new(ROM::Relation[:memory]) do
        schema { attribute :id, ROM::Types::Coercible::Int }
      end.new([])

      expect(relation.input_schema[id: '1']).to eql(id: 1)
    end

    it 'returns a plain Hash coercer when there is no schema' do
      relation = Class.new(ROM::Relation[:memory]).new([])

      tuple = [[:id, '1']]

      expect(relation.input_schema[tuple]).to eql(id: '1')
    end
  end
end
