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

  shared_context 'relation with views' do
    before do
      relation << { id: 1, name: 'Joe' }
      relation << { id: 2, name: 'Jane' }
    end

    it 'infers base view from the schema' do
      expect(relation.attributes).to eql(%i[id name])
    end

    it 'uses projected schema for view attributes' do
      expect(relation.attributes(:names).map(&:name)).to eql(%i[name])
    end

    it 'auto-projects the relation via schema' do
      new_rel = relation_class.new([{ name: 'Jane' }, { name: 'Joe' }])
      names_schema = relation_class.attributes[:names]

      expect(names_schema).to receive(:project_relation).with(relation).and_return(new_rel)
      expect(relation.names).to eql(new_rel)
    end

    it 'auto-projects a restricted relation via schema' do
      new_rel = relation_class.new([{ id: 2 }])
      ids_schema = relation_class.attributes[:ids_for_names]

      expect(ids_schema).to receive(:project_relation).with(relation.restrict(name: ['Jane'])).and_return(new_rel)
      expect(relation.ids_for_names(['Jane'])).to eql(new_rel)
    end
  end

  context 'with an explicit schema' do
    before do
      # this is normally called automatically during setup
      relation_class.schema_defined!
    end

    include_context 'relation with views' do
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

          view(:ids_for_names) do
            schema do
              project(:id)
            end

            relation do |names|
              restrict(name: names)
            end
          end
        end
      end
    end
  end

  context 'with an inferred schema' do
    before do
      # this is normally called automatically during setup
      relation_class.schema.finalize!
      relation_class.schema_defined!
      relation_class.finalize({}, relation)
    end

    include_context 'relation with views' do
      let(:relation_class) do
        Class.new(ROM::Memory::Relation) do
          use :view

          schema_inferrer -> dataset, gateway {
            { id: ROM::Types::Int.meta(name: :id),
              name: ROM::Types::String.meta(name: :name) }
          }

          schema(infer: true)

          view(:names) do
            schema do
              project(:name)
            end

            relation do
              self
            end
          end

          view(:ids_for_names) do
            schema do
              project(:id)
            end

            relation do |names|
              restrict(name: names)
            end
          end
        end
      end
    end
  end
end
