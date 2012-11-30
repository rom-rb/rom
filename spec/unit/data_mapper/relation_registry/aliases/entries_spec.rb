require 'spec_helper'

describe RelationRegistry::Aliases, '#entries' do
  subject { object.entries }

  let(:object) { subclass.new(songs_entries, songs_aliases) }

  let(:songs_entries) {{
    :songs_id    => :songs_id,
    :songs_title => :songs_title,
  }}

  let(:songs_aliases) {{
    :id    => :songs_id,
    :title => :songs_title,
  }}

  it { should respond_to(:each) }
  it { should respond_to(:to_hash) }
end
