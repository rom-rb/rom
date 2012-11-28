require 'spec_helper'

describe Relationship::JoinDefinition, '#each' do
  let(:object)     { described_class.new(left, right) }

  let(:left)       { described_class::Side.new(left_name, left_keys) }
  let(:left_name)  { :songs }
  let(:left_keys)  { [ :id, :title ] }

  let(:right)      { described_class::Side.new(right_name, right_keys) }
  let(:right_name) { :song_tags }
  let(:right_keys) { [ :song_id, :tag_id ] }

  context "with a block" do
    subject { object.each { |left, right| yields[left] = right } }

    let(:yields) { {} }

    before do
      object.should be_instance_of(described_class)
    end

    it_should_behave_like 'an #each method'

    it 'yields each mapping' do
      expect { subject }.to change { yields.dup }.
        from({}).
        to(
          :songs_id    => :song_tags_song_id,
          :songs_title => :song_tags_tag_id
        )
    end
  end
end

describe Relationship::JoinDefinition do
  subject { described_class.new(left, right) }

  let(:object)     { described_class }

  let(:left)       { described_class::Side.new(left_name, left_keys) }
  let(:left_name)  { :songs }
  let(:left_keys)  { [:id] }

  let(:right)      { described_class::Side.new(right_name, right_keys) }
  let(:right_name) { :song_tags }
  let(:right_keys) { [:song_id] }


  before do
    subject.should be_instance_of(object)
  end

  it { should be_kind_of(Enumerable) }

  it 'case matches Enumerable' do
    (Enumerable === subject).should be(true)
  end
end
