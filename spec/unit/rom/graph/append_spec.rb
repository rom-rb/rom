require 'spec_helper'

describe Graph, '#<<' do
  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:registry) { described_class.new }

  it "adds relation to the registry" do
    registry << relation
    registry[:users].relation.should be(relation)
  end
end
