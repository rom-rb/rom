require 'spec_helper'

describe Engine, '#relations' do
  subject { object.relations }

  let(:object) { described_class.new }

  it { should be_instance_of(RelationRegistry) }

  specify { object.relations.engine.should be(object) }
end
