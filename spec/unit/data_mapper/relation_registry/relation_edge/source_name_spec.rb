require 'spec_helper'

describe RelationRegistry::RelationEdge, '#source_name' do
  subject { object.source_name }

  let(:object) { described_class.new(name, left, right) }

  let(:name)        { :orders }
  let(:left)        { mock('users', :name => source_name) }
  let(:right)       { mock('orders') }
  let(:source_name) { mock('source_name')}

  it { should be(source_name) }
end
