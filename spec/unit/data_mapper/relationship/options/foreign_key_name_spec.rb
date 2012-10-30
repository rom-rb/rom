require 'spec_helper'

describe Relationship::Options, '#foreign_key_name' do
  subject { object.foreign_key_name(class_name) }

  let(:object)       { described_class.new(:name, source_model, target_model) }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }
  let(:class_name)   { 'User' }

  it { should be(:user_id) }
end
