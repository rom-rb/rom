require 'spec_helper'

describe Relationship, '#max' do
  subject { object.max }

  let(:object)       { described_class.new(name, source_model, target_model, options) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when :max is not present in options' do
    let(:options) { {} }

    it { should == 1 }
  end

  context 'when :max is present in options' do
    let(:options) { { :max => max } }
    let(:max)     { 2 }

    it { should == max }
  end
end
