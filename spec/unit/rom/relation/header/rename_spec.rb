require 'spec_helper'

describe Relation::Header, '#rename' do
  subject { object.rename(aliases) }

  let(:object) { described_class.new(songs_index, songs_relation_index) }

  let(:songs_index) { described_class::AttributeIndex.new(songs_entries, strategy) }
  let(:strategy)    { described_class::JoinStrategy::NaturalJoin }

  let(:songs_entries) {{
    attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
    attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
  }}

  let(:songs_relation_index) {
    described_class::RelationIndex.new({
      :songs => 1
    })
  }

  let(:aliases) {{
    :id    => :foo_id,
    :title => :foo_title
  }}

  let(:expected_index) { described_class::AttributeIndex.new(expected_entries, strategy) }

  let(:expected_entries) {{
    attribute_alias(:id,    :songs) => attribute_alias(:foo_id,    :songs),
    attribute_alias(:title, :songs) => attribute_alias(:foo_title, :songs),
  }}

  it { should be_instance_of(object.class) }

  its(:attribute_index) { should eql(expected_index) }
  its(:relation_index)  { should eql(songs_relation_index) }
  its(:aliases)         { should eql(aliases) }
end
