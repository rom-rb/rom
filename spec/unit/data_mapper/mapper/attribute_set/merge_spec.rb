require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#merge' do
  subject { object.merge(other) }

  let(:object) { described_class.new }
  let(:other)  { described_class.new }
  let(:id)     { mock('id',   :name => :id,   :field => 'id') }
  let(:name)   { mock('name', :name => :name, :field => 'name') }

  before do
    object << id
    other  << name

    id.should_receive(:clone).with(:to => 'id').and_return(id)
    name.should_receive(:clone).with(:to => 'name').and_return(name)
  end

  it { should include(id) }
  it { should include(name) }
end
