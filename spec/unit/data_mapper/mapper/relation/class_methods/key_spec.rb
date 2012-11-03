require 'spec_helper'

describe Mapper::Relation, '.key' do
  subject { object.key(:id) }

  let(:object) { Class.new(described_class) }

  let(:id) { Mapper::Attribute.build(:id, :type => Integer) }

  before { object.attributes << id }

  it { should be(object) }

  it "sets given attribute as the key" do
    subject.attributes[:id].should be_key
  end
end
