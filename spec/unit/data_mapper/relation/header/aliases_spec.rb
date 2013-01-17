require 'spec_helper'

describe Relation::Header, '#aliases' do
  subject { object.aliases }

  before do
    object.should be_instance_of(described_class)
  end

  context 'with a block' do

    context "using Header::JoinStrategy::NaturalJoin" do

      let(:strategy) { described_class::JoinStrategy::NaturalJoin }

      let(:songs_relation_index) {
        described_class::RelationIndex.new({
          :songs => 1
        })
      }

      let(:song_tags_relation_index) {
        described_class::RelationIndex.new({
          :song_tags => 1
        })
      }

      context "when no join has been performed" do
        let(:object) { described_class.new(songs_index, songs_relation_index) }

        let(:songs_index) { described_class::AttributeIndex.new(songs_entries, strategy) }

        let(:songs_entries) {{
          attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
          attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
        }}

        it { should eql({}) }
      end

      context "when a self join is performed" do

        let(:songs)     { described_class.new(songs_index, songs_relation_index) }
        let(:song_tags) { described_class.new(song_tags_index, song_tags_relation_index) }

        let(:songs_index)       { described_class::AttributeIndex.new(songs_entries, strategy) }
        let(:song_tags_index)   { described_class::AttributeIndex.new(song_tags_entries, strategy) }

        let(:songs_entries) {{
          attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
          attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
        }}

        let(:song_tags_entries) {{
          attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
          attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
        }}

        context "directly" do

          let(:object) { songs.join(songs, join_definition) }

          let(:join_definition) {{
            :title => :title
          }}

          it { should eql(:id => :songs_2_id) }
        end

        context "indirectly" do

          let(:object) { songs_X_song_tags.join(songs, other_join_definition) }

          let(:songs_X_song_tags) { songs.join(song_tags, join_definition) }

          let(:join_definition) {{
            :id => :song_id
          }}

          let(:other_join_definition) {{
            :song_id => :id
          }}

          it { should eql(:title => :songs_2_title) }
        end

      end

      context "when a join has been performed" do

        let(:object) { songs.join(song_tags, join_definition) }

        let(:songs)     { described_class.new(songs_index, songs_relation_index) }
        let(:song_tags) { described_class.new(song_tags_index, song_tags_relation_index) }

        let(:songs_index)     { described_class::AttributeIndex.new(songs_entries, strategy) }
        let(:song_tags_index) { described_class::AttributeIndex.new(song_tags_entries, strategy) }

        let(:join_definition) {{
          :id => :song_id
        }}

        context "with no clashing attribute names" do

          let(:songs_entries) {{
            attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
            attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
          }}

          let(:song_tags_entries) {{
            attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
            attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
          }}

          it { should eql(:song_id => :id) }
        end

        context "with clashing attribute names" do

          context "on the right side only" do

            context "after renaming the right side join attributes" do

              let(:songs_entries) {{
                attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
                attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
              }}

              let(:song_tags_entries) {{
                attribute_alias(:id,      :song_tags) => attribute_alias(:id,      :song_tags),
                attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
                attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
              }}

              it {
                should eql(
                  :song_id => :id,
                  :id      => :song_tags_id
                )
              }
            end

          end

          context "on both sides" do

            context "and the only clashing attribute is not part of the join attributes" do
              let(:songs_entries) {{
                attribute_alias(:id,         :songs) => attribute_alias(:id,         :songs),
                attribute_alias(:title,      :songs) => attribute_alias(:title,      :songs),
                attribute_alias(:created_at, :songs) => attribute_alias(:created_at, :songs),
              }}

              let(:song_tags_entries) {{
                attribute_alias(:song_id,    :song_tags) => attribute_alias(:song_id,    :song_tags),
                attribute_alias(:tag_id,     :song_tags) => attribute_alias(:tag_id,     :song_tags),
                attribute_alias(:created_at, :song_tags) => attribute_alias(:created_at, :song_tags),
              }}

              it {
                should eql(
                  :song_id    => :id,
                  :created_at => :song_tags_created_at
                )
              }
            end

            context "and one clashing attribute is part of the join attributes and the other not" do
              let(:songs_entries) {{
                attribute_alias(:id,         :songs) => attribute_alias(:id,         :songs),
                attribute_alias(:title,      :songs) => attribute_alias(:title,      :songs),
                attribute_alias(:created_at, :songs) => attribute_alias(:created_at, :songs),
              }}

              let(:song_tags_entries) {{
                attribute_alias(:id,         :song_tags) => attribute_alias(:id,         :song_tags),
                attribute_alias(:song_id,    :song_tags) => attribute_alias(:song_id,    :song_tags),
                attribute_alias(:tag_id,     :song_tags) => attribute_alias(:tag_id,     :song_tags),
                attribute_alias(:created_at, :song_tags) => attribute_alias(:created_at, :song_tags),
              }}

              it {
                should eql(
                  :id         => :song_tags_id,
                  :song_id    => :id,
                  :created_at => :song_tags_created_at
                )
              }
            end

          end
        end

        context "and the left join key has been renamed before already" do

          let(:object) { songs_X_song_tags.join(song_comments, other_join_definition) }

          let(:other_join_definition) {{
            :id => :song_id
          }}

          let(:songs_X_song_tags) { songs.join(song_tags, join_definition) }
          let(:song_comments)     { described_class.new(song_comments_index, song_comments_relation_index) }

          let(:song_comments_index) { described_class::AttributeIndex.new(song_comments_entries, strategy) }

          let(:songs_entries) {{
            attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
            attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
          }}

          let(:song_tags_entries) {{
            attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
            attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
          }}

          let(:song_comments_entries) {{
            attribute_alias(:song_id,    :song_comments) => attribute_alias(:song_id,    :song_comments),
            attribute_alias(:comment_id, :song_comments) => attribute_alias(:comment_id, :song_comments),
          }}

          let(:song_comments_relation_index) {
            described_class::RelationIndex.new({
              :song_comments => 1
            })
          }

          it { should eql(:song_id => :id) }
        end

      end
    end
  end
end

describe DataMapper::Relation::Header do
  subject { object.new(attribute_index, relation_index) }

  let(:object)          { described_class }
  let(:attribute_index) { mock('attribute_index', :header => mock) }
  let(:relation_index)  { mock('relation_index') }

  before do
    subject.should be_instance_of(object)
  end

  it { should be_kind_of(Enumerable) }

  it 'case matches Enumerable' do
    (Enumerable === subject).should be(true)
  end
end
