require 'spec_helper'

describe RelationRegistry, '#new_node' do
  subject { registry.new_node(name, relation, aliases) }

  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:registry) { described_class.new(TEST_ENGINE) }

  context "without aliases" do
    let(:aliases) { nil }

    it "adds relation to the registry" do
      subject[:users].relation.should be(relation)
    end
  end

  context "with aliases" do
    let(:aliases) { mock('aliases') }

    it "adds node to the registry with aliases" do
      subject[:users].aliases.should be(aliases)
    end
  end
end
