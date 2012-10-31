require 'spec_helper'

describe Relationship, '#collection_target?' do
  subject { object.collection_target? }

  let(:options) { Relationship::Options.new(:group, mock_model('User'), mock_model('Group')) }
  let(:object)  { described_class.new(options) }

  it { should be(false) }
end
