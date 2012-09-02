require 'spec_helper'

describe DataMapper::Mapper::Attribute::Primitive, '#primitive?' do
  subject { attribute.primitive? }

  let(:attribute) { described_class.new(:title) }

  it { should be(true) }
end
