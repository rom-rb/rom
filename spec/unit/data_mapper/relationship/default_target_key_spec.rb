require 'spec_helper'

describe Relationship, '#default_target_key' do
  subject { object.default_target_key }

  let(:object)       { subclass.new(:name, source_model, target_model) }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  it { should be_nil }
end
