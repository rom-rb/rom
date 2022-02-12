# frozen_string_literal: true

require "rom/setup"

RSpec.describe ROM::Setup, "#register_relation" do
  subject(:setup) do
    ROM::Setup.new
  end

  let(:registry) do
    setup.registry
  end

  it "registers a relation class using provided component's id" do
    stub_const("Users", Class.new(ROM::Relation) { config.component.id = :users })

    setup.register_relation(Users)

    expect(registry["relations.users"]).to be_instance_of(Users)
  end

  it "registers a relation class with component's id inferred from the class name" do
    setup.config.relation.infer_id_from_class = true

    stub_const("Users", Class.new(ROM::Relation))

    setup.register_relation(Users)

    expect(registry["relations.users"]).to be_instance_of(Users)
  end
end
