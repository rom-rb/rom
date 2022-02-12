# frozen_string_literal: true

require "rom/runtime"

RSpec.describe ROM::Runtime, "#register_relation" do
  subject(:runtime) do
    ROM::Runtime.new
  end

  let(:registry) do
    runtime.registry
  end

  it "registers a relation class using provided component's id" do
    stub_const("Users", Class.new(ROM::Relation) { config.component.id = :users })

    runtime.register_relation(Users)

    expect(registry["relations.users"]).to be_instance_of(Users)
  end

  it "registers a relation class with component's id inferred from the class name" do
    runtime.config.relation.infer_id_from_class = true

    stub_const("Users", Class.new(ROM::Relation))

    runtime.register_relation(Users)

    expect(registry["relations.users"]).to be_instance_of(Users)
  end
end
