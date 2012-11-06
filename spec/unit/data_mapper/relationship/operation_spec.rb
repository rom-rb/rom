require 'spec_helper'

describe Relationship, '#operation' do
  subject { object.operation }

  let(:object)       { described_class.new(name, source_model, target_model, options) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when :operation is not present in options' do
    let(:options) { {} }

    it { should be(nil) }
  end

  context 'when :operation is present in options' do
    let(:options)   { { :operation => operation } }
    let(:operation) { mock('Operation')           }

    it { should be(operation) }
  end
end
