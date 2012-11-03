require 'spec_helper'

describe Mapper::Relation, '#one' do
  subject { object.one(options) }

  let(:object)   { mock_mapper(model).new(relation) }
  let(:relation) { mock('relation') }
  let(:model)    { mock_model(:User) }
  let(:options)  { {} }

  before do
    object.should_receive(:find).with(options).and_return(result)
  end

  context "when 1 result is returned" do
    let(:result) { [ :foo ] }

    it { should be(:foo) }
  end

  context "when more than 1 result is returned" do
    let(:result) { [ :foo, :bar ] }

    specify do
      expect { subject }.to raise_error("#{object}#one returned more than one result")
    end
  end
end
