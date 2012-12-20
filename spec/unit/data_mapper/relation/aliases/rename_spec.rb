require 'spec_helper'

describe Relation::Aliases, '#rename' do
  subject { object.rename(aliases) }

  let(:object) { described_class.new(songs_index) }

  let(:songs_index) { described_class::Index.new(songs_entries, strategy) }
  let(:strategy)    { described_class::Strategy::NaturalJoin }

  let(:songs_entries) {{
    attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
    attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
  }}

  let(:aliases) {{
    :id    => :foo_id,
    :title => :foo_title
  }}

  let(:expected_index) { described_class::Index.new(expected_entries, strategy) }

  let(:expected_entries) {{
    attribute_alias(:id,    :songs) => attribute_alias(:foo_id,    :songs),
    attribute_alias(:title, :songs) => attribute_alias(:foo_title, :songs),
  }}

  it { should be_instance_of(object.class) }

  its(:index) { should eql(expected_index) }
end
