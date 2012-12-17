require 'spec_helper'

describe Relation::Aliases, '#index' do
  subject { object.send(:index) }

  context "when using Aliases::Strategy::NaturalJoin" do

    let(:strategy) { described_class::Strategy::NaturalJoin }

    context "when no join has been performed" do
      let(:object) { described_class.new(songs_index) }

      let(:songs_index) { described_class::Index.new(songs_entries, strategy) }

      let(:songs_entries) {{
        attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
        attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
      }}

      it { should eql(described_class::Index.new(songs_entries, strategy)) }
    end

    context "when a join has been performed" do

      let(:object) { songs.join(song_tags, join_definition) }

      let(:songs)     { described_class.new(songs_index) }
      let(:song_tags) { described_class.new(song_tags_index) }

      let(:songs_index)     { described_class::Index.new(songs_entries, strategy) }
      let(:song_tags_index) { described_class::Index.new(song_tags_entries, strategy) }

      let(:join_definition) {{
        :id => :song_id
      }}

      context "with unique attribute names across both relations" do

        let(:songs_entries) {{
          attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
          attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
        }}

        let(:song_tags_entries) {{
          attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
          attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
        }}

        it "should contain field mappings for all attributes" do
          subject.should eql(described_class::Index.new({
            attribute_alias(:id,      :songs)     => attribute_alias(:song_id, :songs),
            attribute_alias(:title,   :songs)     => attribute_alias(:title,   :songs),
            attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
            attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
          }, strategy))
        end
      end

      context "and the left join key has been renamed before already" do

        let(:object) { songs_X_song_tags.join(song_comments, other_join_definition) }

        let(:other_join_definition) {{
          :song_id => :song_id
        }}

        let(:songs_X_song_tags) { songs.join(song_tags, join_definition) }
        let(:song_comments)     { described_class.new(song_comments_index) }

        let(:song_comments_index) { described_class::Index.new(song_comments_entries, strategy) }

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

        it "should contain field mappings for all attributes" do
          subject.should eql(described_class::Index.new({
            attribute_alias(:id,         :songs)         => attribute_alias(:song_id,    :songs),
            attribute_alias(:title,      :songs)         => attribute_alias(:title,      :songs),
            attribute_alias(:song_id,    :song_tags)     => attribute_alias(:song_id,    :song_tags),
            attribute_alias(:tag_id,     :song_tags)     => attribute_alias(:tag_id,     :song_tags),
            attribute_alias(:song_id,    :song_comments) => attribute_alias(:song_id,    :song_comments),
            attribute_alias(:comment_id, :song_comments) => attribute_alias(:comment_id, :song_comments),
          }, strategy))
        end
      end

      context "with clashing attribute names" do

        context "only before renaming join keys" do

          let(:songs_entries) {{
            attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
            attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
          }}

          let(:song_tags_entries) {{
            attribute_alias(:id,      :song_tags) => attribute_alias(:id,      :song_tags),
            attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
            attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
          }}

          it "should contain field mappings for all attributes" do
            subject.should eql(described_class::Index.new({
              attribute_alias(:id,      :songs)     => attribute_alias(:song_id, :songs),
              attribute_alias(:title,   :songs)     => attribute_alias(:title,   :songs),
              attribute_alias(:id,      :song_tags) => attribute_alias(:id,      :song_tags),
              attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
              attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
            }, strategy))
          end
        end

        context "before and after renaming join keys" do

          context "and the clashing attribute is not part of the join keys" do
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

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                attribute_alias(:id,         :songs)     => attribute_alias(:song_id,    :songs),
                attribute_alias(:title,      :songs)     => attribute_alias(:title,      :songs),
                attribute_alias(:created_at, :songs)     => attribute_alias(:created_at, :songs, true),
                attribute_alias(:song_id,    :song_tags) => attribute_alias(:song_id,    :song_tags),
                attribute_alias(:tag_id,     :song_tags) => attribute_alias(:tag_id,     :song_tags),
                attribute_alias(:created_at, :song_tags) => attribute_alias(:created_at, :song_tags),
              }, strategy))
            end
          end

          context "and the clashing attribute matches a join key" do

            let(:songs_entries) {{
              attribute_alias(:id,      :songs) => attribute_alias(:id,      :songs),
              attribute_alias(:title,   :songs) => attribute_alias(:title,   :songs),
              attribute_alias(:song_id, :songs) => attribute_alias(:song_id, :songs),
            }}

            let(:song_tags_entries) {{
              attribute_alias(:id,      :song_tags) => attribute_alias(:id,      :song_tags),
              attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
              attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
            }}

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                attribute_alias(:id,      :songs)     => attribute_alias(:song_id, :songs),
                attribute_alias(:title,   :songs)     => attribute_alias(:title,   :songs),
                attribute_alias(:song_id, :songs)     => attribute_alias(:song_id, :songs, true),
                attribute_alias(:id,      :song_tags) => attribute_alias(:id,      :song_tags),
                attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
                attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
              }, strategy))
            end
          end

        end
      end
    end

  end
end
