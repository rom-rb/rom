require 'rom'
require 'rom/memory'
require 'rom/plugins/relation/view'

RSpec.describe ROM::Plugins::Relation::View do
  subject(:relation) { relation_class.new(ROM::Memory::Dataset.new([])) }

  context 'without a schema' do
    let(:relation_class) do
      Class.new(ROM::Memory::Relation) do
        use :view

        view(:base, [:id, :name]) do
          self
        end

        view(:ids, [:id]) do
          self
        end

        view(:names, [:name]) do |id|
          self
        end
      end
    end

    describe '#attributes' do
      it 'returns base view attributes by default' do
        expect(relation.attributes).to eql([:id, :name])
      end

      it 'returns attributes for a view' do
        expect(relation.ids.attributes).to eql([:id])
      end

      it 'returns attributes for a view with args' do
        expect(relation.names(1).attributes).to eql([:name])
      end

      it 'returns attributes for a curried view' do
        expect(relation.names.attributes).to eql([:name])
      end

      it 'returns correct arity for a curried view' do
        expect(relation.names.arity).to be(1)
      end

      it 'returns explicitly set attributes' do
        expect(relation.with(attributes: [:foo, :bar]).attributes).to eql([:foo, :bar])
      end
    end
  end

  context 'with a schema' do
    before do
      # this is normally called automatically during setup
      relation_class.schema_defined!
    end

    describe 'base view attributes' do
      let(:relation_class) do
        Class.new(ROM::Memory::Relation) do
          use :view

          schema do
            attribute :id, ROM::Types::Int
            attribute :name, ROM::Types::String
          end
        end
      end

      it 'infers base view from the schema' do
        expect(relation.attributes).to eql(%i[id name])
      end
    end

    describe 're-using schema in a view definition' do
      let(:relation_class) do
        Class.new(ROM::Memory::Relation) do
          use :view

          schema do
            attribute :id, ROM::Types::Int
            attribute :name, ROM::Types::String
          end

          view(:names) do
            schema do
              project(:name) 
            end

            relation do
              self 
            end
          end
        end
      end

      before do
        relation << { id: 1, name: 'Joe' }
        relation << { id: 2, name: 'Jane' }
      end

      it 'uses projected schema for view attributes' do
        expect(relation.attributes(:names)).to eql(%i[name])
      end

      it 'auto-projects the relation via schema' do
        new_rel = relation_class.new([{ name: 'Jane' }, { name: 'Joe' }])

        expect(relation_class.attributes[:names])
          .to receive(:project_relation).with(relation).and_return(new_rel)

        expect(relation.names).to eql(new_rel)
      end
    end
  end
end
