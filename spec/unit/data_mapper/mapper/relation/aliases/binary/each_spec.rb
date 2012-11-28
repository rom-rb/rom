require 'spec_helper'

describe Mapper::Relation::Aliases::Binary, '#each' do
  subject { object.each { |field, aliased_field| yields[field] = aliased_field } }

  let(:yields) { {} }

  let(:songs) { Mapper::Relation::Aliases::Unary.new(songs_entries, songs_aliases) }

  let(:songs_entries) {{
    :songs_id    => :songs_id,
    :songs_title => :songs_title,
  }}

  let(:songs_aliases) {{
    :id    => :songs_id,
    :title => :songs_title,
  }}

  let(:song_tags) { Mapper::Relation::Aliases::Unary.new(song_tags_entries, song_tags_aliases) }

  let(:song_tags_entries) {{
    :song_tags_song_id => :song_tags_song_id,
    :song_tags_tag_id  => :song_tags_tag_id,
  }}

  let(:song_tags_aliases) {{
    :song_id => :song_tags_song_id,
    :tag_id  => :song_tags_tag_id,
  }}

  let(:tags) { Mapper::Relation::Aliases::Unary.new(tags_entries, tags_aliases) }

  let(:tags_entries) {{
    :tags_id   => :tags_id,
    :tags_name => :tags_name,
  }}

  let(:tags_aliases) {{
    :tags_id   => :tags_id,
    :tags_name => :tags_name,
  }}

  let(:infos) { Mapper::Relation::Aliases::Unary.new(infos_entries, infos_aliases) }

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

  let(:song_comments) { Mapper::Relation::Aliases::Unary.new(song_comments_entries, song_comments_aliases) }

  let(:song_comments_entries) {{
    :song_comments_song_id    => :song_comments_song_id,
    :song_comments_comment_id => :song_comments_comment_id,
    :song_comments_created_at => :song_comments_created_at,
  }}

  let(:song_comments_aliases) {{
    :song_id    => :song_comments_song_id,
    :comment_id => :song_comments_comment_id,
  }}

  let(:comments) { Mapper::Relation::Aliases::Unary.new(comments_entries, comments_aliases) }

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

  before do
    object.should be_instance_of(described_class)
  end

  context 'with a block' do

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

      context "and a M:N relationship" do
        let(:object) { songs_X_song_tags }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(
              :id    => :song_tags_song_id,
              :title => :songs_title
            )
        end
      end

      context "and a M:N relationship that goes through 1:N via M:1" do
        let(:object) { songs_X_song_tags_X_tags }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(:song_tags_tag_id => :tags_id)
        end
      end

      context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N" do
        let(:object) { songs_X_song_tags_X_tags_X_infos }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(:tags_id => :infos_tag_id)
        end
      end

      context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N that joins on source" do
        let(:object) { songs_X_song_tags_X_tags_X_song_comments }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(:song_tags_song_id => :song_comments_song_id)
        end
      end

      context "and a M:N relationship that goes through 1:N ((through 1:N via M:1) via 1:N that joins on source) via 1:N" do
        let(:object) { songs_X_song_tags_X_tags_X_song_comments_X_comments }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(:song_comments_comment_id => :comments_id)
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

      context "and a M:N relationship" do
        let(:object) { songs_X_song_tags }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(
              :id    => :song_tags_song_id,
              :title => :song_tags_tag_id
            )
        end
      end

      context "and a M:N relationship that goes through 1:N via M:1" do
        let(:object) { songs_X_song_tags_X_tags }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(
              :song_tags_tag_id  => :tags_id,
              :song_tags_song_id => :tags_name
            )
        end
      end

      context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N" do
        let(:object) { songs_X_song_tags_X_tags_X_infos }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(
              :tags_id   => :infos_tag_id,
              :tags_name => :infos_text
            )
        end
      end

      context "and a M:N relationship that goes through 1:N (through 1:N via M:1) via 1:N that joins on source" do
        let(:object) { songs_X_song_tags_X_tags_X_song_comments }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(
              :tags_name => :song_comments_song_id,
              :tags_id   => :song_comments_created_at
            )
        end
      end

      context "and a M:N relationship that goes through 1:N ((through 1:N via M:1) via 1:N that joins on source) via 1:N" do
        let(:object) { songs_X_song_tags_X_tags_X_song_comments_X_comments }

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to change { yields.dup }.
            from({}).
            to(
              :song_comments_comment_id => :comments_id,
              :song_comments_created_at => :comments_text
            )
        end
      end
    end
  end
end

describe Mapper::Relation::Aliases::Binary do
  subject { object.new(entries, aliases) }

  let(:entries) { mock('entries', :to_hash => {}, :values => []) }
  let(:aliases) { mock('aliases', :to_hash => {}) }

  let(:object) { described_class }

  before do
    subject.should be_instance_of(object)
  end

  it { should be_kind_of(Enumerable) }

  it 'case matches Enumerable' do
    (Enumerable === subject).should be(true)
  end
end
