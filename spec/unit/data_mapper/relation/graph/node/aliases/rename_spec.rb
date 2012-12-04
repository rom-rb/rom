require 'spec_helper'

describe Relation::Graph::Node::Aliases, '#rename' do
  subject { object.rename(aliases) }

  let(:object) { subclass.new(songs_entries, songs_aliases) }

  let(:songs_entries) {{
    :songs_id    => :songs_id,
    :songs_title => :songs_title,
  }}

  let(:songs_aliases) {{
    :id    => :songs_id,
    :title => :songs_title,
  }}

  let(:aliases) {{
    :songs_id    => :songs_foo_id,
    :songs_title => :songs_foo_title
  }}

  let(:expected_entries) {{
    :songs_id    => :songs_foo_id,
    :songs_title => :songs_foo_title,
  }}

  it { should be_instance_of(object.class) }

  its(:entries) { should eql(expected_entries) }
end
