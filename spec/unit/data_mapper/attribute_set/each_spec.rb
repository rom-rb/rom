require 'spec_helper'

describe AttributeSet, '#each' do
  subject { attributes.each.to_a }

  let(:attributes) { described_class.new }
  let(:id)         { mock('id',   :name => :id) }
  let(:name)       { mock('name', :name => :name) }

  before { attributes << id << name }

  it { should have(2).items }
  it { should include(id) }
  it { should include(name) }
end
