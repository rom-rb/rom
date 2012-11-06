require 'spec_helper'

describe Engine, '#base_relation' do
  subject { object.base_relation(relation) }

  let(:object)   { subclass(:TestEngine).new }
  let(:relation) { mock('relation') }

  specify do
    expect { subject }.to raise_error(NotImplementedError, 'TestEngine#base_relation is not implemented')
  end
end
