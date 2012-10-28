require 'spec_helper'

describe DataMapper::AliasSet, '#each' do
  subject { object.each.to_a }

  let(:object) { described_class.new(prefix, attributes) }

  let(:prefix)     { :user }
  let(:id)         { Mapper::Attribute.build(:id, :type => Integer, :key => true) }
  let(:name)       { Mapper::Attribute.build(:name, :type => String, :to => :username) }
  let(:attributes) { Mapper::AttributeSet.new << id << name }

  it { should have(2).items }
  it { should include([ :id, :user_id             ]) }
  it { should include([ :username, :user_username ]) }
end
