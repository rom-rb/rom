require 'spec_helper'

describe RelationRegistry::Aliases::Unary, '#each' do
  subject { object.each { |field, aliased_field| yields[field] = aliased_field } }

  let(:yields) { {} }

  let(:songs) { described_class.new(songs_entries, songs_aliases) }

  let(:songs_entries) {{
    :songs_id    => :songs_id,
    :songs_title => :songs_title,
  }}

  let(:songs_aliases) {{
    :id    => :songs_id,
    :title => :songs_title,
  }}

  before do
    object.should be_instance_of(described_class)
  end

  context 'with a block' do
    let(:object) { songs }

    it_should_behave_like 'an #each method'

    it 'yields correct aliases' do
      expect { subject }.to change { yields.dup }.
        from({}).
        to(
          :id    => :songs_id,
          :title => :songs_title
        )
    end
  end
end

describe RelationRegistry::Aliases::Unary do
  subject { object.new(entries, aliases) }

  let(:entries) { mock('entries', :to_hash => {}, :values => []) }
  let(:aliases) { mock('aliases', :to_hash => {}, :keys   => [], :invert => {}) }

  let(:object) { described_class }

  before do
    subject.should be_instance_of(object)
  end

  it { should be_kind_of(Enumerable) }

  it 'case matches Enumerable' do
    (Enumerable === subject).should be(true)
  end
end
