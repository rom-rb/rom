require 'spec_helper'

describe Engine, '#relations' do
  subject { object.relations }

  let(:object) { described_class.new(uri) }
  let(:uri)    { 'something://somewhere/test' }

  it { should be_instance_of(Relation::Graph) }

  specify { object.relations.engine.should be(object) }
end
