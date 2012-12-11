require 'spec_helper'

describe Relation::Graph::Node::Aliases, '#index' do
  subject { object.send(:index) }

  context "when using Aliases::Strategy::NaturalJoin" do

    let(:strategy) { described_class::Strategy::NaturalJoin }

    context "when no join has been performed" do
      let(:object) { described_class.new(songs_index) }

      let(:songs_index) { described_class::Index.new(songs_entries, strategy) }

      let(:songs_entries) {{
        :songs_id    => :id,
        :songs_title => :title,
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
          :songs_id    => :id,
          :songs_title => :title,
        }}

        let(:song_tags_entries) {{
          :song_tags_song_id => :song_id,
          :song_tags_tag_id  => :tag_id,
        }}

        it "should contain field mappings for all attributes" do
          subject.should eql(described_class::Index.new({
            :songs_id          => :song_id,
            :songs_title       => :title,
            :song_tags_song_id => :song_id,
            :song_tags_tag_id  => :tag_id,
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
          :songs_id    => :id,
          :songs_title => :title,
        }}

        let(:song_tags_entries) {{
          :song_tags_song_id => :song_id,
          :song_tags_tag_id  => :tag_id,
        }}

        let(:song_comments_entries) {{
          :song_comments_song_id    => :song_id,
          :song_comments_comment_id => :comment_id,
        }}

        it "should contain field mappings for all attributes" do
          subject.should eql(described_class::Index.new({
            :songs_id                 => :song_id,
            :songs_title              => :title,
            :song_tags_song_id        => :song_id,
            :song_tags_tag_id         => :tag_id,
            :song_comments_song_id    => :song_id,
            :song_comments_comment_id => :comment_id,
          }, strategy))
        end
      end

      context "with clashing attribute names" do

        context "only before renaming join keys" do

          let(:songs_entries) {{
            :songs_id    => :id,
            :songs_title => :title,
          }}

          let(:song_tags_entries) {{
            :song_tags_id      => :id,
            :song_tags_song_id => :song_id,
            :song_tags_tag_id  => :tag_id,
          }}

          it "should contain field mappings for all attributes" do
            subject.should eql(described_class::Index.new({
              :songs_id          => :song_id,
              :songs_title       => :title,
              :song_tags_id      => :id,
              :song_tags_song_id => :song_id,
              :song_tags_tag_id  => :tag_id,
            }, strategy))
          end
        end

        context "before and after renaming join keys" do

          context "and the clashing attribute is not part of the join keys" do
            let(:songs_entries) {{
              :songs_id         => :id,
              :songs_title      => :title,
              :songs_created_at => :created_at
            }}

            let(:song_tags_entries) {{
              :song_tags_song_id    => :song_id,
              :song_tags_tag_id     => :tag_id,
              :song_tags_created_at => :created_at,
            }}

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                :songs_id             => :song_id,
                :songs_title          => :title,
                :songs_created_at     => :songs_created_at,
                :song_tags_song_id    => :song_id,
                :song_tags_tag_id     => :tag_id,
                :song_tags_created_at => :created_at,
              }, strategy))
            end
          end

          context "and the clashing attribute matches a join key" do

            let(:songs_entries) {{
              :songs_id      => :id,
              :songs_title   => :title,
              :songs_song_id => :song_id,
            }}

            let(:song_tags_entries) {{
              :song_tags_id      => :id,
              :song_tags_song_id => :song_id,
              :song_tags_tag_id  => :tag_id,
            }}

            it "should contain field mappings for all attributes" do
              subject.should eql(described_class::Index.new({
                :songs_id          => :song_id,
                :songs_title       => :title,
                :songs_song_id     => :songs_song_id,
                :song_tags_id      => :id,
                :song_tags_song_id => :song_id,
                :song_tags_tag_id  => :tag_id,
              }, strategy))
            end
          end

        end
      end
    end

  end
end
