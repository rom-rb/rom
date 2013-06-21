require 'spec_helper'

describe Session::State do
  subject(:state) { described_class.new(object, relation) }

  let(:relation) { fake(:relation) }
  let(:model)    { mock_model(:id, :name) }
  let(:object)   { model.new(:id => 1, :name => 'Jane') }

end
