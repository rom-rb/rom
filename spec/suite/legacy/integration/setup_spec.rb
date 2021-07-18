# frozen_string_literal: true

RSpec.describe "Plugins / schema / :timestamps" do
  subject(:schema) { container.relations[:users].schema }

  let(:runtime) { ROM::Runtime.new(:memory) }
  let(:container) { ROM.runtime(runtime) }

  it "allows setting timestamps in all schemas" do
    runtime.plugin(:memory, schemas: :timestamps)

    runtime.relation(:users)

    expect(schema.to_h.keys).to eql(%i[created_at updated_at])
  end

  it "accepts options" do
    runtime.plugin(:memory, schemas: :timestamps) do |p|
      p.attributes = %i[created_on updated_on]
    end

    runtime.relation(:users)

    expect(schema.to_h.keys).to eql(%i[created_on updated_on])
  end

  it "extends schema dsl" do
    runtime.plugin(:memory, schemas: :timestamps)

    runtime.relation(:users) do
      schema do
        timestamps :created_on, :updated_on
      end
    end

    expect(schema.to_h.keys).to eql(%i[created_on updated_on])
  end
end
