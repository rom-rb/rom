require 'spec_helper'

describe Query, '#each' do
  let(:object) { described_class.new(options, attributes) }

  let(:options)    { { :name => 'Piotr', :age => 29 } }
  let(:attributes) { AttributeSet.new         }

  let(:name) { Attribute.build(:name, :type => String,  :to => :user_name) }
  let(:age)  { Attribute.build(:age,  :type => Integer, :to => :user_age)  }

  before { attributes << name << age }

  context "with a block" do
    subject { object.to_a }

    it { should have(2).items }
    it { should include([:user_name, 'Piotr']) }
    it { should include([:user_age, 29]) }
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
