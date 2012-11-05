require 'spec_helper'

describe DataMapper::Mapper::Attribute, '#clone' do
  subject { attribute.clone(options) }

  let(:attribute) { described_class.new(name, :type => type) }
  let(:name)      { :title }
  let(:type)      { String }

  let(:options) {{
    :to         => field,
    :key        => key,
    :type       => Integer,
    :collection => true
  }}

  let(:field) { :book_title }
  let(:key)   { true        }

  its(:field) { should be(field) }
  its(:key?)  { should be(key)   }

  it 'does not change the attribute name' do
    subject.name.should == name
  end

  it 'does not change the attribute type' do
    subject.type.should == type
  end

  it 'does not change the :collection option' do
    subject.options[:collection].should be(nil)
  end
end

