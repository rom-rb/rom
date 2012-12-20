require 'spec_helper'

describe DataMapper::Attribute, '#primitive?' do
  subject { attribute.primitive? }

  let(:attribute) { subclass.new(:name) }

  it { should be(false) }
end
