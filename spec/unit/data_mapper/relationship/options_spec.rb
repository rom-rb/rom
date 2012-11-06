require 'spec_helper'

describe Relationship, '#options' do
  subject { object.options }

  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when no options are passed to #initialize' do
    let(:object) { described_class.new(name, source_model, target_model) }

    it { should == {} }
  end

  context 'when options are passed to initialize' do
    let(:object)  { described_class.new(name, source_model, target_model, options) }
    let(:options) { { :through => :song_tags } }

    it { should be(options) }
  end
end
