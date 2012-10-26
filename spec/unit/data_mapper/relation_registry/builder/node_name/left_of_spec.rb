require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#left_of' do
  subject { object.left_of(name) }

  let(:object) { described_class.new('song_tags_X_tags', 'infos') }
  let(:name)   { :infos }

  it { should eql(:song_tags_X_tags) }
end
