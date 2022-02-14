# frozen_string_literal: true

RSpec.describe ROM::Relation, ".use" do
  subject(:relation) do
    Class.new(ROM::Relation)
  end

  let(:plugin) do
    relation.config.component.plugins.first
  end

  it "enables a plugin for the relation" do
    relation.use(:instrumentation)

    expect(plugin).to be_enabled
    expect(plugin.config.target).to be(relation)
  end

  it "sets custom config" do
    relation.use(:instrumentation, foo: "bar")

    expect(plugin).to be_enabled
    expect(plugin.config.foo).to eql("bar")
    expect(plugin.config.target).to be(relation)
  end
end
