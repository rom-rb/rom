require 'spec_helper'

describe Relationship, '#default_target_key' do
  subject { object.default_target_key }

  let(:options) { Relationship::Options.new(:group, mock_model('User'), mock_model('Group')) }
  let(:object)  { described_class.new(options) }

  it { should be(:group_id) }
end
