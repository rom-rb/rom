# frozen_string_literal: true

RSpec.describe "ROM::Relation.schema" do
  include_context "container"

  it "supports associations DSL" do
    configuration.relation(:users) do
      schema(infer: true) do
        associations do
          has_many :tasks
        end
      end
    end

    expect(container.relations.users.associations.map(&:name)).to eql([:tasks])
  end
end
