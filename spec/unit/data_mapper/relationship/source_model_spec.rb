require 'spec_helper'

describe Relationship, '#source_model' do
  subject { object.source_model }

  let(:object)       { described_class.new(name, source_model, target_model) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  it { should be(source_model) }
end
