require 'spec_helper'

describe RelationRegistry, '#<<' do
  let(:name)     { :users }
  let(:relation) { OpenStruct.new(:name => name) }
  let(:registry) { described_class.new }

  it "adds relation to the registry" do
    registry << relation
    expect(registry[name].relation).to be(relation)
  end
end
