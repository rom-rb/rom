require 'spec_helper'

describe Relation::Graph::Node::Aliases, '#each' do
  subject { object.each { |field, aliased_field| yields[field] = aliased_field } }

  let(:yields) { {} }

  before do
    object.should be_instance_of(described_class)
  end

  context 'with a block' do

    context "using Aliases::Strategy::NaturalJoin" do

      let(:strategy) { described_class::Strategy::NaturalJoin }

      context "when no join has been performed" do
        let(:object) { described_class.new(songs_index) }

        let(:songs_index) { described_class::Index.new(songs_entries, strategy) }

        let(:songs_entries) {{
          :songs_id    => :id,
          :songs_title => :title,
        }}

        it_should_behave_like 'an #each method'

        it 'yields correct aliases' do
          expect { subject }.to_not change { yields.dup }
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

        context "with unique attribute names across both relations" do

          let(:songs_entries) {{
            :songs_id    => :id,
            :songs_title => :title,
          }}

          let(:song_tags_entries) {{
            :song_tags_song_id => :song_id,
            :song_tags_tag_id  => :tag_id,
          }}

          it_should_behave_like 'an #each method'

          it 'yields correct aliases' do
            expect { subject }.to change { yields.dup }.
              from({}).
              to(:id => :song_id)
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

          it_should_behave_like 'an #each method'

          it 'yields correct aliases' do
            expect { subject }.to_not change { yields.dup }
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

            it_should_behave_like 'an #each method'

            it 'yields correct aliases' do
              expect { subject }.to change { yields.dup }.
                from({}).
                to(:id => :song_id)
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

              it_should_behave_like 'an #each method'

              it 'yields correct aliases' do
                expect { subject }.to change { yields.dup }.
                  from({}).
                  to(
                    :id         => :song_id,
                    :created_at => :songs_created_at
                  )
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

              it_should_behave_like 'an #each method'

              it 'yields correct aliases' do
                expect { subject }.to change { yields.dup }.
                  from({}).
                  to(
                    :id      => :song_id,
                    :song_id => :songs_song_id
                  )
              end
            end

          end
        end
      end


    end
  end
end

describe DataMapper::Relation::Graph::Node::Aliases do
  subject { object.new(index) }

  let(:object) { described_class }
  let(:index)  { mock('index', :header => mock) }

  before do
    subject.should be_instance_of(object)
  end

  it { should be_kind_of(Enumerable) }

  it 'case matches Enumerable' do
    (Enumerable === subject).should be(true)
  end
end
