require 'spec_helper'

describe Relation::Graph::Node::Aliases, '#rename' do
  subject { object.rename(aliases) }

  let(:object) { described_class.new(songs_index) }

  let(:songs_index) { described_class::Index.new(songs_entries, strategy) }
  let(:strategy)    { described_class::Strategy::NaturalJoin }

  let(:songs_entries) {{
    :songs_id    => :id,
    :songs_title => :title,
  }}

  let(:aliases) {{
    :id    => :foo_id,
    :title => :foo_title
  }}

  let(:expected_index) { described_class::Index.new(expected_entries, strategy) }

  let(:expected_entries) {{
    :songs_id    => :foo_id,
    :songs_title => :foo_title,
  }}

  it { should be_instance_of(object.class) }

  its(:index) { should eql(expected_index) }
end
