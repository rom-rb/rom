require 'spec_helper'

describe Relationship, '#via' do
  subject { object.via }

  let(:object)       { subclass.new(name, source_model, target_model, options) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when :through is not present in options' do
    let(:options) { {} }

    it { should be(nil) }
  end

  context 'when :through is present in options' do
    let(:options) { { :through => via } }
    let(:via)     { :song_tags }

    it { should be(via) }
  end
end
