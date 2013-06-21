require 'spec_helper'

describe Session::Tracker do
  subject(:tracker) { described_class.new(relations) }

  let(:users)     { fake(:relation) }
  let(:relations) { Hash[:users => users] }
  let(:model)     { mock_model(:id, :name) }
  let(:object)    { model.new }

end
