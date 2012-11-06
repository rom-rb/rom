require 'spec_helper'

describe Relationship, '#name' do
  subject { object.name }

  let(:object)       { described_class.new(name, source_model, target_model) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  it { should == name }
end
