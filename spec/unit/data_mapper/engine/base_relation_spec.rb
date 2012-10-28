require 'spec_helper'

describe Engine, '#base_relation' do
  let(:object)   { described_class.new }
  let(:relation) { mock('relation') }

  specify do
    expect { object.base_relation(relation) }.to raise_error(
      NotImplementedError, 'DataMapper::Engine#base_relation must be implemented')
  end
end
