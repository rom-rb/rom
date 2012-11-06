require 'spec_helper'

describe Relationship, '#source_key' do
  subject { object.source_key }

  let(:object)       { described_class.new(name, source_model, target_model, options) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when :source_key is not present in options' do
    let(:options) { {} }

    it 'uses #default_source_key' do
      subject.should be(object.default_source_key)
    end
  end

  context 'when :source_key is present in options' do
    let(:options)    { { :source_key => source_key } }
    let(:source_key) { :id }

    it { should be(source_key) }
  end
end
