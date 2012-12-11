require 'spec_helper'

describe Relation::Graph::Node::Aliases, '#entries' do
  subject { object.entries }

  context "when no join has been performed" do
    let(:object) { described_class.new(songs_entries) }

    let(:songs_entries) {{
      :songs_id    => :id,
      :songs_title => :title,
    }}

    it { should be(songs_entries) }
    it { should respond_to(:each) }
    it { should respond_to(:to_hash) }
  end

  context "when a join has been performed" do

    let(:object) { songs.join(song_tags, join_definition) }

    let(:songs)     { described_class.new(songs_entries) }
    let(:song_tags) { described_class.new(song_tags_entries) }

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

      it { should be_instance_of(Hash) }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :song_id,
          :songs_title       => :title,
          :song_tags_song_id => :song_id,
          :song_tags_tag_id  => :tag_id,
        })
      end
    end

    context "and the left join key has been renamed before already" do

      let(:object) { songs_X_song_tags.join(song_comments, other_join_definition) }

      let(:other_join_definition) {{
        :song_id => :song_id
      }}

      let(:songs_X_song_tags) { songs.join(song_tags, join_definition) }
      let(:song_comments)     { described_class.new(song_comments_entries) }

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

      it { should be_instance_of(Hash) }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id                 => :song_id,
          :songs_title              => :title,
          :song_tags_song_id        => :song_id,
          :song_tags_tag_id         => :tag_id,
          :song_comments_song_id    => :song_id,
          :song_comments_comment_id => :comment_id,
        })
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

        it { should be_instance_of(Hash) }

        it "should contain field mappings for all attributes" do
          subject.should eql({
            :songs_id          => :song_id,
            :songs_title       => :title,
            :song_tags_id      => :id,
            :song_tags_song_id => :song_id,
            :song_tags_tag_id  => :tag_id,
          })
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

          it { should be_instance_of(Hash) }

          it "should contain field mappings for all attributes" do
            subject.should eql({
              :songs_id             => :song_id,
              :songs_title          => :title,
              :songs_created_at     => :songs_created_at,
              :song_tags_song_id    => :song_id,
              :song_tags_tag_id     => :tag_id,
              :song_tags_created_at => :created_at,
            })
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

          it { should be_instance_of(Hash) }

          it "should contain field mappings for all attributes" do
            subject.should eql({
              :songs_id          => :song_id,
              :songs_title       => :title,
              :songs_song_id     => :songs_song_id,
              :song_tags_id      => :id,
              :song_tags_song_id => :song_id,
              :song_tags_tag_id  => :tag_id,
            })
          end
        end

      end
    end
  end
end
