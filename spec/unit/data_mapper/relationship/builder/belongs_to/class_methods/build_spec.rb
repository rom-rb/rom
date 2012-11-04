require 'spec_helper'

describe Relationship::Builder::BelongsTo, '.build' do
  subject { described_class.build(source, name, target_model, options) }

  let(:source)       { mock_mapper(source_model) }
  let(:source_model) { mock_model(:User) }
  let(:target_model) { mock_model(:Address) }
  let(:name)         { :address }
  let(:options)      { {} }

  it { should be_instance_of(Relationship::ManyToOne) }

  its(:name)         { should be(name) }
  its(:source_model) { should be(source_model) }
  its(:target_model) { should be(target_model) }
end
