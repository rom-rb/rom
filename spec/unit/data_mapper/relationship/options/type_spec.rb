require 'spec_helper'

describe Relationship::Options, '#type' do
  subject { object.type }

  let(:object)       { described_class.new(:name, source_model, target_model) }
  let(:source_model) { mock('source_model') }
  let(:target_model) { mock('target_model') }

  specify do
    expect { subject }.to raise_error(
      NotImplementedError, "DataMapper::Relationship::Options#type must be implemented"
    )
  end
end
