require 'spec_helper'

describe DataMapper::Mapper::Attribute::Mapper, '#primitive?' do
  let(:type) { mock('type') }

  it_should_behave_like "DataMapper::Mapper::Attribute::Mapper#primitive?"
end
