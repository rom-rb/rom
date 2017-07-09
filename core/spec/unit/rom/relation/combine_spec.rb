require 'rom/relation'

RSpec.describe ROM::Relation, '#combine' do
  let(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:tasks) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tasks])
  end

  let(:tags) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tags])
  end

  let(:users_assocs_set) do
    { tasks: tasks_assoc }
  end

  let(:tasks_assocs_set) do
    { tags: tags_assoc }
  end

  let(:tasks_assoc) do
    double(:tasks_assoc)
  end

  let(:tags_assoc) do
    double(:tags_assoc)
  end

  before do
    allow(users.schema).to receive(:associations).and_return(users_assocs_set)
    allow(tasks.schema).to receive(:associations).and_return(tasks_assocs_set)
  end

  context 'with a list of assoc names' do
    it 'returns a combined relation' do
      tasks_node = double(:tasks_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      relation = users.combine(:tasks)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks])
    end
  end

  context 'with a hash with nested assocs' do
    it 'returns a combined relation' do
      tasks_node = double(:tasks_node)
      tags_node = double(:tags_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      expect(tags_assoc).to receive(:node).and_return(tags_node)
      expect(tags_node).to receive(:eager_load).with(tags_assoc).and_return(tags)

      relation = users.combine(tasks: :tags)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks.combine(:tags)])
    end
  end

  context 'with a hash with nested assocs as an array' do
    it 'returns a combined relation' do
      tasks_node = double(:tasks_node)
      tags_node = double(:tags_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      expect(tags_assoc).to receive(:node).and_return(tags_node)
      expect(tags_node).to receive(:eager_load).with(tags_assoc).and_return(tags)

      relation = users.combine(tasks: [:tags])

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks.combine(:tags)])
    end
  end
end
