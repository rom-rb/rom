# frozen_string_literal: true

require "rom/compat"

RSpec.describe ROM::Configuration, "#relation_classes" do
  it "returns the list of relations associated with a gateway" do
    conf = ROM::Configuration.new(default: [:memory], custom: [:memory])

    default_gw = conf.gateways[:default]
    custom_gw = conf.gateways[:custom]

    rel_default = Class.new(ROM::Relation[:memory]) { schema(:users) {} }
    rel_custom = Class.new(ROM::Relation[:memory]) { gateway :custom
 schema(:others) {}
}                 

    conf.register_relation(rel_default)
    conf.register_relation(rel_custom)

    expect(conf.relation_classes).to eql([rel_default, rel_custom])
    expect(conf.relation_classes(default_gw)).to eql([rel_default])
    expect(conf.relation_classes(:default)).to eql([rel_default])
    expect(conf.relation_classes(custom_gw)).to eql([rel_custom])
    expect(conf.relation_classes(:custom)).to eql([rel_custom])
  end
end
