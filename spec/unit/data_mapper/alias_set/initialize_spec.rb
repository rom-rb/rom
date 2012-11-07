require 'spec_helper'

describe AliasSet, '#initialize' do
  let(:prefix)     { :songs                                         }
  let(:attributes) { Mapper::AttributeSet.new << attribute          }
  let(:attribute)  { Mapper::Attribute.build(:id, :type => Integer) }
  let(:excluded)   { [ :id ]                                        }

  context 'with prefix passed to #initialize' do
    subject { described_class.new(prefix) }

    its(:prefix)     { should == prefix }
    its(:attributes) { should == Mapper::AttributeSet.new }
    its(:excluded)   { should == [] }
    its(:to_hash)    { should == {} }
  end

  context 'with prefix and attributes passed to #initialize' do
    subject { described_class.new(prefix, attributes) }

    its(:prefix)     { should == prefix     }
    its(:attributes) { should == attributes }
    its(:excluded)   { should == []         }
    its(:to_hash)    { should == { :id => :songs_id } }
  end

  context 'with prefix, attributes and excluded passed to #initialize' do
    subject { described_class.new(prefix, attributes, excluded) }

    its(:prefix)     { should == prefix     }
    its(:attributes) { should == attributes }
    its(:excluded)   { should == excluded   }
    its(:to_hash)    { should == {}         }
  end
end
