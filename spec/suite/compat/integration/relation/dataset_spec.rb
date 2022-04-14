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
  end

  let(:users) do
    container.relations[:users]
  end

  it "allows defining custom dataset" do
    expect(users.dataset).to eql([users.schema, users.class])
  end
end
