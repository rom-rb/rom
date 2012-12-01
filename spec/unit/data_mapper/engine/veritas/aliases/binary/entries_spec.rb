require 'spec_helper'

describe Engine::Veritas::Aliases::Binary, '#entries' do
  subject { object.entries }

  let(:songs) { Engine::Veritas::Aliases::Unary.new(songs_entries, songs_aliases) }

  let(:songs_entries) {{
    :songs_id    => :songs_id,
    :songs_title => :songs_title,
  }}

  let(:songs_aliases) {{
    :id    => :songs_id,
    :title => :songs_title,
  }}

  let(:song_tags) { Engine::Veritas::Aliases::Unary.new(song_tags_entries, song_tags_aliases) }

  let(:song_tags_entries) {{
    :song_tags_song_id => :song_tags_song_id,
    :song_tags_tag_id  => :song_tags_tag_id,
  }}

  let(:song_tags_aliases) {{
    :song_id => :song_tags_song_id,
    :tag_id  => :song_tags_tag_id,
  }}

  let(:tags) {Engine::Veritas::Aliases::Unary.new(tags_entries, tags_aliases) }

  let(:tags_entries) {{
    :tags_id   => :tags_id,
    :tags_name => :tags_name,
  }}

  let(:tags_aliases) {{
    :tags_id   => :tags_id,
    :tags_name => :tags_name,
  }}

  let(:infos) { Engine::Veritas::Aliases::Unary.new(infos_entries, infos_aliases) }

  let(:infos_entries) {{
    :infos_id     => :infos_id,
    :infos_tag_id => :infos_tag_id,
    :infos_text   => :infos_text,
  }}

  let(:infos_aliases) {{
    :id     => :infos_id,
    :tag_id => :infos_tag_id,
    :text   => :infos_text,
  }}

  let(:song_comments) { Engine::Veritas::Aliases::Unary.new(song_comments_entries, song_comments_aliases) }

  let(:song_comments_entries) {{
    :song_comments_song_id    => :song_comments_song_id,
    :song_comments_comment_id => :song_comments_comment_id,
    :song_comments_created_at => :song_comments_created_at,
  }}

  let(:song_comments_aliases) {{
    :song_id    => :song_comments_song_id,
    :comment_id => :song_comments_comment_id,
  }}

  let(:comments) { Engine::Veritas::Aliases::Unary.new(comments_entries, comments_aliases) }

  let(:comments_entries) {{
    :comments_id   => :comments_id,
    :comments_text => :comments_text,
  }}

  let(:comments_aliases) {{
    :id   => :comments_id,
    :text => :comments_text,
  }}

  let(:songs_X_song_tags) {
    songs.join(song_tags, songs_X_song_tags_join_keys)
  }

  let(:songs_X_song_tags_X_tags) {
    songs_X_song_tags.join(tags, songs_X_song_tags_X_tags_join_keys)
  }

  let(:songs_X_song_tags_X_tags_X_infos) {
    songs_X_song_tags_X_tags.join(infos, songs_X_song_tags_X_tags_X_infos_join_keys)
  }

  let(:songs_X_song_tags_X_tags_X_song_comments) {
    songs_X_song_tags_X_tags.join(song_comments, songs_X_song_tags_X_tags_X_song_comments_join_keys)
  }

  let(:songs_X_song_tags_X_tags_X_song_comments_X_comments) {
    songs_X_song_tags_X_tags_X_song_comments.join(comments, songs_X_song_tags_X_tags_X_song_comments_X_comments_join_keys)
  }

  context "when joining with a non composite key" do

    let(:songs_X_song_tags_join_keys) {{
      :songs_id => :song_tags_song_id
    }}

    let(:songs_X_song_tags_X_tags_join_keys) {{
      :song_tags_tag_id => :tags_id
    }}

    let(:songs_X_song_tags_X_tags_X_infos_join_keys) {{
      :tags_id => :infos_tag_id
    }}

    let(:songs_X_song_tags_X_tags_X_song_comments_join_keys) {{
      :songs_id => :song_comments_song_id
    }}

    let(:songs_X_song_tags_X_tags_X_song_comments_X_comments_join_keys) {{
      :song_comments_comment_id => :comments_id
    }}

    context "and a 1:N relationship" do
      let(:object) { songs_X_song_tags }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :song_tags_song_id,
          :songs_title       => :songs_title,
          :song_tags_song_id => :song_tags_song_id,
          :song_tags_tag_id  => :song_tags_tag_id,
        })
      end
    end

    context "and a M:N relationship that goes through 1:N via M:1" do
      let(:object) { songs_X_song_tags_X_tags }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :song_tags_song_id,
          :songs_title       => :songs_title,
          :song_tags_song_id => :song_tags_song_id,
          :song_tags_tag_id  => :tags_id,
          :tags_id           => :tags_id,
          :tags_name         => :tags_name,
        })
      end
    end

    context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N" do
      let(:object) { songs_X_song_tags_X_tags_X_infos }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :song_tags_song_id,
          :songs_title       => :songs_title,
          :song_tags_song_id => :song_tags_song_id,
          :song_tags_tag_id  => :infos_tag_id,
          :tags_id           => :infos_tag_id,
          :tags_name         => :tags_name,
          :infos_id          => :infos_id,
          :infos_tag_id      => :infos_tag_id,
          :infos_text        => :infos_text,
        })
      end
    end

    context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N that joins on source" do
      let(:object) { songs_X_song_tags_X_tags_X_song_comments }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id                 => :song_comments_song_id,
          :songs_title              => :songs_title,
          :song_tags_song_id        => :song_comments_song_id,
          :song_tags_tag_id         => :tags_id,
          :tags_id                  => :tags_id,
          :tags_name                => :tags_name,
          :song_comments_song_id    => :song_comments_song_id,
          :song_comments_comment_id => :song_comments_comment_id,
          :song_comments_created_at => :song_comments_created_at
        })
      end
    end

    context "and a M:N relationship that goes through 1:N ((through 1:N via M:1) via 1:N that joins on source) via 1:N" do
      let(:object) { songs_X_song_tags_X_tags_X_song_comments_X_comments }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id                 => :song_comments_song_id,
          :songs_title              => :songs_title,
          :song_tags_song_id        => :song_comments_song_id,
          :song_tags_tag_id         => :tags_id,
          :tags_id                  => :tags_id,
          :tags_name                => :tags_name,
          :song_comments_song_id    => :song_comments_song_id,
          :song_comments_comment_id => :comments_id,
          :song_comments_created_at => :song_comments_created_at,
          :comments_id              => :comments_id,
          :comments_text            => :comments_text
        })
      end
    end
  end

  context "when joining with a composite key" do

    let(:songs_X_song_tags_join_keys) {{
      :songs_id    => :song_tags_song_id,
      :songs_title => :song_tags_tag_id
    }}

    let(:songs_X_song_tags_X_tags_join_keys) {{
      :song_tags_tag_id  => :tags_id,
      :song_tags_song_id => :tags_name
    }}

    let(:songs_X_song_tags_X_tags_X_infos_join_keys) {{
      :tags_id   => :infos_tag_id,
      :tags_name => :infos_text
    }}

    let(:songs_X_song_tags_X_tags_X_song_comments_join_keys) {{
      :songs_id    => :song_comments_song_id,
      :songs_title => :song_comments_created_at
    }}

    let(:songs_X_song_tags_X_tags_X_song_comments_X_comments_join_keys) {{
      :song_comments_comment_id => :comments_id,
      :song_comments_created_at => :comments_text
    }}

    context "and a 1:N relationship" do
      let(:object) { songs_X_song_tags }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :song_tags_song_id,
          :songs_title       => :song_tags_tag_id,
          :song_tags_song_id => :song_tags_song_id,
          :song_tags_tag_id  => :song_tags_tag_id,
        })
      end
    end

    context "and a M:N relationship that goes through 1:N via M:1" do
      let(:object) { songs_X_song_tags_X_tags }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :tags_name,
          :songs_title       => :tags_id,
          :song_tags_song_id => :tags_name,
          :song_tags_tag_id  => :tags_id,
          :tags_id           => :tags_id,
          :tags_name         => :tags_name,
        })
      end
    end

    context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N" do
      let(:object) { songs_X_song_tags_X_tags_X_infos }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id          => :infos_text,
          :songs_title       => :infos_tag_id,
          :song_tags_song_id => :infos_text,
          :song_tags_tag_id  => :infos_tag_id,
          :tags_id           => :infos_tag_id,
          :tags_name         => :infos_text,
          :infos_id          => :infos_id,
          :infos_tag_id      => :infos_tag_id,
          :infos_text        => :infos_text,
        })
      end
    end

    context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N that joins on source" do
      let(:object) { songs_X_song_tags_X_tags_X_song_comments }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id                 => :song_comments_song_id,
          :songs_title              => :song_comments_created_at,
          :song_tags_song_id        => :song_comments_song_id,
          :song_tags_tag_id         => :song_comments_created_at,
          :tags_id                  => :song_comments_created_at,
          :tags_name                => :song_comments_song_id,
          :song_comments_song_id    => :song_comments_song_id,
          :song_comments_comment_id => :song_comments_comment_id,
          :song_comments_created_at => :song_comments_created_at
        })
      end
    end

    context "and a M:N relationship that goes through 1:N ((through 1:N via M:1) via 1:N that joins on source) via 1:N" do
      let(:object) { songs_X_song_tags_X_tags_X_song_comments_X_comments }

      it "should contain field mappings for all attributes" do
        subject.should eql({
          :songs_id                 => :song_comments_song_id,
          :songs_title              => :comments_text,
          :song_tags_song_id        => :song_comments_song_id,
          :song_tags_tag_id         => :comments_text,
          :tags_id                  => :comments_text,
          :tags_name                => :song_comments_song_id,
          :song_comments_song_id    => :song_comments_song_id,
          :song_comments_comment_id => :comments_id,
          :song_comments_created_at => :comments_text,
          :comments_id              => :comments_id,
          :comments_text            => :comments_text
        })
      end
    end
  end
end
