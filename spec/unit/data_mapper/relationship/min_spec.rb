require 'spec_helper'

describe Relationship, '#min' do
  subject { object.min }

  let(:object)       { subclass.new(name, source_model, target_model, options) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when :min is not present in options' do
    let(:options) { {} }

    it { should == 1 }
  end

  context 'when :min is present in options' do
    let(:options) { { :min => min } }
    let(:min)     { 0 }

    it { should == min }
  end
end
