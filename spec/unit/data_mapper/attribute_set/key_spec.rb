require 'spec_helper'

describe AttributeSet, '#key' do
  subject { attributes.key }

  let(:attributes) { described_class.new }

  let(:id)   { mock('id',   :name => :id,   :key? => true) }
  let(:name) { mock('name', :name => :name, :key? => false) }

  before { attributes << id << name }

  it { should have(1).items }
  it { should include(id) }
end
