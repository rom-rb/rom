require 'spec_helper'

describe Relation::Mapper, '#relations' do
  subject { object.relations }

  let(:object)    { described_class.new(ROM_ENV, relation) }
  let(:relation)  { mock_relation('relation') }
  let(:relations) { mock('relations') }

  it { should be(ROM_ENV.relations) }
end
