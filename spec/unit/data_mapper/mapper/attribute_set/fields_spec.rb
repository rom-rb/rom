require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#fields' do
  subject { attributes.fields }

  let(:attributes) { described_class.new }

  let(:name)    { mock('name',    :name => :name,    :primitive? => true, :header => name_header) }
  let(:age)     { mock('age',     :name => :age,     :primitive? => true, :header => age_header) }
  let(:address) { mock('address', :name => :address, :primitive? => false) }

  let(:name_header) { [ :Name, String ] }
  let(:age_header)  { [ :Age, Integer ] }

  before do
    attributes << name << age << address
  end

  it { should have(2).items }
  it { should include(:Name) }
  it { should include(:Age) }
end
