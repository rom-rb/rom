require 'spec_helper'

describe Repository, '#adapter' do
  subject { object.adapter }

  let(:object)  { described_class.new(name, adapter) }
  let(:name)    { mock }
  let(:adapter) { mock }

  it { should be(adapter) }
end
