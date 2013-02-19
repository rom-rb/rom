require 'spec_helper'

describe Repository, '#name' do
  subject { object.name }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { mock }
  let(:adapter)  { mock }

  it { should be(name) }
end
