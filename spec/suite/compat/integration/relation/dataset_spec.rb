# frozen_string_literal: true

RSpec.describe "ROM::Relation.dataset" do
  include_context "container"

  before do
    configuration.relation(:users) do
      schema do
        attribute :id, ROM::Types::Integer
        attribute :name, ROM::Types::String
      end

      subscribe("configuration.relations.schema.set", adapter: :memory) do |event|
        schema = event[:schema]
        relation = event[:relation]

        relation.dataset do |klass|
          [schema, klass]
        end
      end
    end

    configuration.relation(:tasks) do
      schema do
        attribute :id, ROM::Types::Integer
        attribute :title, ROM::Types::String
      end

      dataset do |schema|
        [schema]
      end
    end
  end

  let(:users) do
    container.relations[:users]
  end

  let(:tasks) do
    container.relations[:tasks]
  end

  it "allows defining custom dataset" do
    expect(users.dataset).to eql([users.schema, users.class])
    expect(tasks.dataset).to eql([tasks.schema])
  end
end
