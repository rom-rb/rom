require 'spec_helper'

describe Mapper::AttributeSet, '#alias_index' do
  subject { attributes.alias_index(prefix) }

  let(:attributes) { described_class.new }
  let(:prefix)     { 'user' }
  let(:id)         { Mapper::Attribute.build(:id,      :type => Integer)  }
  let(:name)       { Mapper::Attribute.build(:name,    :type => String) }
  let(:address)    { Mapper::Attribute.build(:address, :type => mock_model('Address'))}

  before { attributes << id << name << address }

  it { should eql(:id => :user_id, :name => :user_name) }
end
