require 'spec_helper'

describe DataMapper::Mapper::RelationRegistry, '#[]=' do
  let(:name)     { :users }
  let(:relation) { mock('relation', :name => name) }
  let(:registry) { described_class.new }

  it 'adds relation to the registry' do
    registry[name] = relation
    registry[name].should be(relation)
  end
end
