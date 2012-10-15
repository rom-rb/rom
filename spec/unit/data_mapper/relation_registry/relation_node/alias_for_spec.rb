require 'spec_helper'

describe RelationRegistry::RelationNode, '#alias_for' do
  subject { object.alias_for(:id) }

  let(:object)       { described_class.new(relation) }
  let(:relationship) { mock_relation(:address, [ :id, Integer ]) }

  it { should be(:address__id) }
end
