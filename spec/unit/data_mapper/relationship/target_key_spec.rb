require 'spec_helper'

describe Relationship, '#target_key' do
  subject { object.target_key }

  let(:object)       { subclass.new(name, source_model, target_model, options) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  context 'when :target_key is not present in options' do
    let(:options) { {} }

    it 'uses #default_target_key' do
      subject.should eql(object.send(:default_target_key))
    end
  end

  context 'when :target_key is present in options' do
    let(:options)    { { :target_key => target_key } }
    let(:target_key) { [ :song_id ] }

    it { should be(target_key) }
  end
end
