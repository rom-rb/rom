# frozen_string_literal: true

require "rom/core"
require "rom/memory"

RSpec.describe ROM::Relation, ".view" do
  subject(:relation) do
    rom.relations[:users]
  end

  let(:tasks) do
    Class.new(ROM::Relation[:memory]) do
      schema(:tasks) do
        attribute :title, ROM::Types::String
      end
    end
  end

  let(:rom) do
    ROM.container(:memory) { |runtime|
      runtime.register_relation(relation_class, tasks)
    }
  end

  it "returns view method name" do
    klass = Class.new(ROM::Relation[:memory]) {
      schema(:users) { attribute :id, ROM::Types::Integer }
    }

    name = klass.view(:by_id, []) { self }

    expect(name).to be(:by_id)
  end

  it "raises an error when attributes are not provided" do
    klass = Class.new(ROM::Relation[:memory])

    expect { klass.view(:broken) { |r| r } }
      .to raise_error(ArgumentError, "schema attribute names must be provided as the second argument")
  end

  shared_context "relation with views" do
    before do
      relation << {id: 1, name: "Joe"}
      relation << {id: 2, name: "Jane"}
    end

    it "appends foreign attributes" do
      expect(relation.schemas[:foreign_attributes].map(&:name)).to eql(%i[id name title])
    end

    it "uses projected schema for view schema" do
      expect(relation.schemas[:names].map(&:name)).to eql(%i[name])
    end

    it "auto-projects the relation via schema" do
      new_rel = relation_class.new([{name: "Jane"}, {name: "Joe"}])
      names_schema = relation.schemas[:names]

      expect(names_schema).to receive(:call).with(relation).and_return(new_rel)
      expect(relation.names).to eql(new_rel)
    end

    it "auto-projects a restricted relation via schema" do
      new_rel = relation_class.new([{id: 2}])
      ids_schema = relation.schemas[:ids_for_names]

      expect(ids_schema).to receive(:call).with(relation.restrict(name: ["Jane"])).and_return(new_rel)
      expect(relation.ids_for_names(["Jane"])).to eql(new_rel)
    end
  end

  context "with an explicit schema" do
    include_context "relation with views" do
      let(:relation_class) do
        Class.new(ROM::Memory::Relation) do
          schema(:users) do
            attribute :id, ROM::Types::Integer
            attribute :name, ROM::Types::String
          end

          view(:foreign_attributes) do
            schema do
              append(relations[:tasks][:title])
            end

            relation do
              self
            end
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

  context "with an inferred schema" do
    include_context "relation with views" do
      let(:relation_class) do
        attributes_inferrer = proc {
          [[define_attribute(:Integer, name: :id), define_attribute(:String, name: :name)], []]
        }

        Class.new(ROM::Memory::Relation) do
          schema_inferrer ROM::Schema::DEFAULT_INFERRER.with(
            attributes_inferrer: attributes_inferrer
          )

          schema(:users, infer: true)

          view(:foreign_attributes) do
            schema do
              append(relations[:tasks][:title])
            end

            relation do
              self
            end
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
end
