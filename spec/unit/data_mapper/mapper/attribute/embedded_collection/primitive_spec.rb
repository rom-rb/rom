require 'spec_helper'

describe DataMapper::Mapper::Attribute::EmbeddedCollection, '#primitive?' do
  it_should_behave_like "DataMapper::Mapper::Attribute::EmbeddedValue#primitive?"
end
