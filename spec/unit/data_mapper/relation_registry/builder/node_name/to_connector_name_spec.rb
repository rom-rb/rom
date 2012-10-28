require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_connector_name' do
  subject { object.to_connector_name }

  let(:object) { described_class.new('song_tags_X_tags', 'infos', 'super_infos') }

  it { should eql(:song_tags_X_tags_X_super_infos) }
end
