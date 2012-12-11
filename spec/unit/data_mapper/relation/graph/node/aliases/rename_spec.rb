require 'spec_helper'

describe Relation::Graph::Node::Aliases, '#rename' do
  subject { object.rename(aliases) }

  let(:object) { subclass.new(songs_entries) }

  let(:songs_entries) {{
    :songs_id    => :id,
    :songs_title => :title,
  }}

  let(:aliases) {{
    :id    => :foo_id,
    :title => :foo_title
  }}

  let(:expected_entries) {{
    :songs_id    => :foo_id,
    :songs_title => :foo_title,
  }}

  it { should be_instance_of(object.class) }

  its(:entries) { should eql(expected_entries) }
end
