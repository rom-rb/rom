# frozen_string_literal: true

require "rom/setup"

RSpec.describe "Plugins / schema / :timestamps" do
  subject(:schema) { registry.relations[:users].schema }

  let(:setup) { ROM::Setup.new(:memory) }
  let(:registry) { setup.finalize }

  it "allows setting timestamps in all schemas" do
    setup.plugin(:memory, schemas: :timestamps)

    setup.relation(:users)

    expect(schema.to_h.keys).to eql(%i[created_at updated_at])
  end

  it "accepts options" do
    setup.plugin(:memory, schemas: :timestamps) do |p|
      p.attributes = %i[created_on updated_on]
    end

    setup.relation(:users)

    expect(schema.to_h.keys).to eql(%i[created_on updated_on])
  end

  it "extends schema dsl" do
    setup.plugin(:memory, schemas: :timestamps)

    setup.relation(:users) do
      schema do
        timestamps :created_on, :updated_on
      end
    end

    expect(schema.to_h.keys).to eql(%i[created_on updated_on])
  end
end
