require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#field_name' do
  subject { attributes.field_name(name) }

  let(:attributes) { described_class.new }

  let(:name)      { :title }
  let(:attribute) { mock('title', :name => name, :field => :BookTitle) }

  before do
    attributes << attribute
  end

  it { should be(:BookTitle) }
end
