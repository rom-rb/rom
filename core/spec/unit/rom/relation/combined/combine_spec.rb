require 'rom/relation/combined'

RSpec.describe ROM::Relation::Combined, '#combine' do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks])
  end

  let(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:tasks) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tasks])
  end

  let(:posts) do
    ROM::Relation.new([], name: ROM::Relation::Name[:posts])
  end

  let(:tags) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tags])
  end

  it 'returns another combined relation with nodes appended' do
    expect(relation.root).to receive(:nodes).with(posts, tags).and_return([posts, tags])

    new_relation = relation.combine(posts, tags)

    expect(new_relation.root).to be(users)
    expect(new_relation.nodes).to eql([tasks, posts, tags])
  end
end
