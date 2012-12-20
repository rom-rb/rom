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

    context "when a self join is performed" do

      let(:songs)     { described_class.new(songs_index) }
      let(:song_tags) { described_class.new(song_tags_index) }

      let(:songs_index)       { described_class::Index.new(songs_entries, strategy) }
      let(:song_tags_index)   { described_class::Index.new(song_tags_entries, strategy) }

      let(:songs_entries) {{
        attribute_alias(:id,    :songs) => attribute_alias(:id,    :songs),
        attribute_alias(:title, :songs) => attribute_alias(:title, :songs),
      }}

      let(:song_tags_entries) {{
        attribute_alias(:song_id, :song_tags) => attribute_alias(:song_id, :song_tags),
        attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id,  :song_tags),
      }}

      context "and no relation aliases have been specified" do

        let(:object) { songs.join(songs, join_definition) }

        let(:join_definition) {{
          :title => :title
        }}

        it "should raise InvalidRelationAliasError" do
          expect { subject }.to raise_error(Relation::Aliases::InvalidRelationAliasError)
        end

      end

      context "and invalid relation aliases have been specified" do

        let(:object) { songs.join(songs, join_definition, relation_aliases) }

        let(:join_definition) {{
          :title => :title
        }}

        let(:relation_aliases) {{
          :foo => :bar
        }}

        it "should raise InvalidRelationAliasError" do
          expect { subject }.to raise_error(Relation::Aliases::InvalidRelationAliasError)
        end

      end

      context "and valid relation aliases have been specified" do

        context "directly" do

          let(:object) { songs.join(songs, join_definition, relation_aliases) }

          let(:join_definition) {{
            :title => :title
          }}

          let(:relation_aliases) {{
            :songs => :songs_2
          }}

          it "should not raise InvalidRelationAliasError" do
            expect { subject }.to_not raise_error(Relation::Aliases::InvalidRelationAliasError)
          end

          it "should contain field mappings for all attributes" do
            pending "direct self joins are not yet implemented"

            subject.should eql(described_class::Index.new({
              attribute_alias(:id,    :songs)   => attribute_alias(:id,    :songs),
              attribute_alias(:title, :songs)   => attribute_alias(:title, :songs),
              attribute_alias(:id,    :songs_1) => attribute_alias(:id,    :songs_1, true),
              attribute_alias(:title, :songs_1) => attribute_alias(:title, :songs_1),
            }, strategy))
          end

        end

        context "indirectly" do

          let(:object) { songs_X_song_tags.join(songs, other_join_definition, relation_aliases) }

          let(:songs_X_song_tags) { songs.join(song_tags, join_definition) }

          let(:join_definition) {{
            :id => :song_id
          }}

          let(:other_join_definition) {{
            :title => :title
          }}

          let(:relation_aliases) {{
            :songs => :songs_2
          }}

          it "should not raise InvalidRelationAliasError" do
            expect { subject }.to_not raise_error(Relation::Aliases::InvalidRelationAliasError)
          end

          it "should contain field mappings for all attributes" do
            pending "indirect self joins are not yet implemented"

            subject.should eql(described_class::Index.new({
              attribute_alias(:id,      :songs)     => attribute_alias(:id,     :songs),
              attribute_alias(:title,   :songs)     => attribute_alias(:title,  :songs),
              attribute_alias(:song_id, :song_tags) => attribute_alias(:id,     :song_tags),
              attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id, :song_tags),
              attribute_alias(:id,      :songs_1)   => attribute_alias(:id,     :songs_1, true),
              attribute_alias(:title,   :songs_1)   => attribute_alias(:title,  :songs_1),
            }, strategy))
          end

        end
      end

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

      context "with no clashing attribute names" do

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
            attribute_alias(:id,      :songs)     => attribute_alias(:id,     :songs),
            attribute_alias(:title,   :songs)     => attribute_alias(:title,  :songs),
            attribute_alias(:song_id, :song_tags) => attribute_alias(:id,     :song_tags),
            attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id, :song_tags),
          }, strategy))
        end
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

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                attribute_alias(:id,      :songs)     => attribute_alias(:id,     :songs),
                attribute_alias(:title,   :songs)     => attribute_alias(:title,  :songs),
                attribute_alias(:id,      :song_tags) => attribute_alias(:id,     :song_tags, true),
                attribute_alias(:song_id, :song_tags) => attribute_alias(:id,     :song_tags),
                attribute_alias(:tag_id,  :song_tags) => attribute_alias(:tag_id, :song_tags),
              }, strategy))
            end
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

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                attribute_alias(:id,         :songs)     => attribute_alias(:id,          :songs),
                attribute_alias(:title,      :songs)     => attribute_alias(:title,       :songs),
                attribute_alias(:created_at, :songs)     => attribute_alias(:created_at,  :songs),
                attribute_alias(:song_id,    :song_tags) => attribute_alias(:id,          :song_tags),
                attribute_alias(:tag_id,     :song_tags) => attribute_alias(:tag_id,      :song_tags),
                attribute_alias(:created_at, :song_tags) => attribute_alias(:created_at,  :song_tags, true),
              }, strategy))
            end
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

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                attribute_alias(:id,         :songs)     => attribute_alias(:id,         :songs),
                attribute_alias(:title,      :songs)     => attribute_alias(:title,      :songs),
                attribute_alias(:created_at, :songs)     => attribute_alias(:created_at, :songs),
                attribute_alias(:id,         :song_tags) => attribute_alias(:id,         :song_tags, true),
                attribute_alias(:song_id,    :song_tags) => attribute_alias(:id,         :song_tags),
                attribute_alias(:tag_id,     :song_tags) => attribute_alias(:tag_id,     :song_tags),
                attribute_alias(:created_at, :song_tags) => attribute_alias(:created_at, :song_tags, true),
              }, strategy))
            end
          end

        end
      end

      context "and the left join key has been renamed before already" do

        let(:object) { songs_X_song_tags.join(song_comments, other_join_definition) }

        let(:other_join_definition) {{
          :id => :song_id
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
            attribute_alias(:id,         :songs)         => attribute_alias(:id,         :songs),
            attribute_alias(:title,      :songs)         => attribute_alias(:title,      :songs),
            attribute_alias(:song_id,    :song_tags)     => attribute_alias(:id,         :song_tags),
            attribute_alias(:tag_id,     :song_tags)     => attribute_alias(:tag_id,     :song_tags),
            attribute_alias(:song_id,    :song_comments) => attribute_alias(:id,         :song_comments),
            attribute_alias(:comment_id, :song_comments) => attribute_alias(:comment_id, :song_comments),
          }, strategy))
        end
      end

    end
  end
end
