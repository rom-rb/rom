require 'spec_helper'

describe Relation::Graph, '#new_node' do
  subject { registry.new_node(name, relation, header) }

  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:registry) { described_class.new(TEST_ENGINE) }

  context "without header" do
    let(:header) { nil }

    it "adds relation to the registry" do
      subject[:users].relation.should be(relation)
    end
  end

  context "with header" do
    let(:header) { mock('header') }

    it "adds node to the registry with header" do
      subject[:users].header.should be(header)
    end
  end
end
