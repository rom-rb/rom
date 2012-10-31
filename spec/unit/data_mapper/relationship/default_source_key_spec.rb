require 'spec_helper'

describe Relationship, '#default_source_key' do
  subject { object.default_source_key }

  let(:options) { Relationship::Options.new(:group, mock_model('User'), mock_model('Group')) }
  let(:object)  { described_class.new(options) }

  it { should be(:id) }
end
