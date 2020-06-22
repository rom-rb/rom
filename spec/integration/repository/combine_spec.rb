# frozen_string_literal: true

RSpec.describe ROM::Relation, '#combine' do
  include_context 'repository / database'
  include_context 'relations'
  include_context 'seeds'

  subject(:combined) do
    users.combine(:posts)
  end

  it 'exposes nodes via `node` method' do
    expect { combined.node(:posts) { |node| node } }.not_to raise_error
  end

  context 'with aliased children and its parents' do
    subject(:user) do
      combined.where(name: 'Jane').one
    end

    let(:combined) do
      users.combine(aliased_posts: :author)
    end

    it 'loads a graph' do
      expect(user[:aliased_posts].count).to be(1)
      expect(user[:aliased_posts][0][:author][:id]).to be(user[:id])
      expect(user[:aliased_posts][0][:author][:name]).to eql(user[:name])
    end
  end

  context 'with nested nodes' do
    let(:combined) do
      users.combine(posts: :labels)
    end

    let(:jane) do
      combined
        .node(:posts) { |posts| posts.where(title: 'Hello From Jane') }
        .node(posts: :labels) { |labels| labels.where(name: 'red') }
        .where(name: 'Jane')
        .one
    end

    it 'exposes nested nodes' do
      expect(jane).to include(
        name: 'Jane',
        posts: all(
          include(
            title: 'Hello From Jane',
            labels: all(include(name: 'red'))
          )
        )
      )
    end
  end

  context 'when invalid relation name was passed to `node` method' do
    let(:message) { ':poztz is not a valid aggregate node name' }

    it 'raises arg error ' do
      expect { combined.node(:poztz) {} }.to raise_error(ArgumentError, message)
    end
  end
end
