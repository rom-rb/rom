require 'spec_helper'

describe AliasSet, '#initialize' do
  let(:relation_name) { :songs                                         }
  let(:attributes)    { Mapper::AttributeSet.new << attribute          }
  let(:attribute)     { Mapper::Attribute.build(:id, :type => Integer) }
  let(:excluded)      { [ :id ]                                        }

  context 'with relation_name passed to #initialize' do
    subject { described_class.new(relation_name) }

    its(:relation_name) { should == relation_name }
    its(:attributes)    { should == Mapper::AttributeSet.new }
    its(:excluded)      { should == [] }
    its(:to_hash)       { should == {} }
  end

  context 'with relation_name and attributes passed to #initialize' do
    subject { described_class.new(relation_name, attributes) }

    its(:relation_name) { should == relation_name }
    its(:attributes)    { should == attributes }
    its(:excluded)      { should == []         }
    its(:to_hash)       { should == { :id => :song_id } }
  end

  context 'with relation_name, attributes and excluded passed to #initialize' do
    subject { described_class.new(relation_name, attributes, excluded) }

    its(:relation_name) { should == relation_name     }
    its(:attributes)    { should == attributes }
    its(:excluded)      { should == excluded   }
    its(:to_hash)       { should == {}         }
  end
end
