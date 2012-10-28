require 'spec_helper'

describe Engine, '#gateway_relation' do
  subject { object.gateway_relation(relation) }

  let(:object)   { described_class.new }
  let(:relation) { mock('relation') }

  it { should be(relation) }
end
