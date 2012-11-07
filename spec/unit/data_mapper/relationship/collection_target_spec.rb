require 'spec_helper'

describe Relationship, '#collection_target?' do
  subject { object.collection_target? }

  let(:object) { subclass.new(:group, mock_model('User'), mock_model('Group')) }

  it { should be(false) }
end
