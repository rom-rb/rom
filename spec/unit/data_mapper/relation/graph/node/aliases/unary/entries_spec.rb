require 'spec_helper'

describe Relation::Graph::Node::Aliases::Unary, '#entries' do
  subject { object.entries }

  let(:object) { described_class.new(songs_entries, songs_aliases) }

  let(:songs_entries) {{
    :songs_id    => :songs_id,
    :songs_title => :songs_title,
  }}

  let(:songs_aliases) {{
    :id    => :songs_id,
    :title => :songs_title,
  }}

  it { should eql(songs_entries) }
end
