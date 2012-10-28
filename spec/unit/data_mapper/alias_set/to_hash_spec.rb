require 'spec_helper'

describe AliasSet, '#to_hash' do
  subject { object.to_hash }

  let(:object) { described_class.new(prefix, attributes) }

  let(:prefix)     { :user }
  let(:id)         { Mapper::Attribute.build(:id, :type => Integer, :key => true) }
  let(:name)       { Mapper::Attribute.build(:name, :type => String, :to => :username) }
  let(:attributes) { Mapper::AttributeSet.new << id << name }

  it { should eql(:id => :user_id, :username => :user_username) }
end
