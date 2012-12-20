require 'spec_helper'

describe AttributeSet, '#key_names' do
  subject { attributes.key_names }

  let(:attributes) { described_class.new }

  let(:id)    { mock('id',    :name => :id,    :key? => true) }
  let(:name)  { mock('name',  :name => :name,  :key? => true) }
  let(:email) { mock('email', :name => :email, :key? => false) }

  before { attributes << id << name << email }

  it { should have(2).items }
  it { should include(:id) }
  it { should include(:name) }
end
