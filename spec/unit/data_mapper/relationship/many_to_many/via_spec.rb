require 'spec_helper'

describe Relationship::ManyToMany, '#via' do
  subject { object.via }

  let(:object)       { subclass.new(name, source_model, target_model, options) }
  let(:name)         { :tags }
  let(:source_model) { mock_model(:Song) }
  let(:target_model) { mock_model(:Tag) }

  context 'when :via is not present in options' do
    let(:options) { {} }

    it { should be(:tag) }
  end

  context 'when :via is present in options' do
    let(:options) { { :via => via } }
    let(:via)     { :special_tag }

    it { should be(via) }
  end
end
