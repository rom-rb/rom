require 'spec_helper'

describe RelationRegistry, '#<<' do
  subject { registry.new_node(name, relation) }

  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:registry) { described_class.new }

  it "adds relation to the registry" do
    subject[:users].relation.should be(relation)
  end
end
