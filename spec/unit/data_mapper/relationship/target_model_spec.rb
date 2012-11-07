require 'spec_helper'

describe Relationship, '#target_model' do
  subject { object.target_model }

  let(:object)       { subclass.new(name, source_model, target_model) }
  let(:name)         { :songs }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  it { should be(target_model) }
end
