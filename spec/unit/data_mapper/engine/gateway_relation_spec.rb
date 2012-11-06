require 'spec_helper'

describe Engine, '#gateway_relation' do
  subject { object.gateway_relation(relation) }

  let(:object)   { subclass.new }
  let(:relation) { mock('relation') }

  it { should be(relation) }
end
