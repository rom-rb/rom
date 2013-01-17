require 'spec_helper'

describe Attribute, '#primitive?' do
  subject { attribute.primitive? }

  let(:attribute) { subclass.new(:name, EMPTY_HASH) }

  it { should be(false) }
end
