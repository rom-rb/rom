require 'spec_helper'

describe DataMapper::Mapper::Attribute, '#primitive?' do
  subject { attribute.primitive? }

  let(:attribute) { subclass.new(:name) }

  it { should be(false) }
end
