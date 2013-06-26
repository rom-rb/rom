require 'spec_helper'

describe Session::Relation, '#new' do
  subject { users.new(attributes) }

  include_context 'Session::Relation'

  let(:attributes) { Hash[:id => 1, :name => 'Jane'] }

  it { should eql(model.new(attributes)) }

  it 'auto-tracks the new object' do
    expect(object.tracking?(subject)).to be_true
  end

  it 'sets state to transient' do
    expect(object.state(subject)).to be_transient
  end
end
