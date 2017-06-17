require 'spec_helper'

RSpec.describe ROM::Relation::Graph do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      def by_name(name)
        restrict(name: name)
      end
    end.new(users_dataset)
  end

  let(:tasks_relation) do
    Class.new(ROM::Memory::Relation) do
      def for_users(_users)
        self
      end

      def by_title(title)
        restrict(title: title)
      end
    end.new(tasks_dataset)
  end

  subject(:graph) { ROM::Relation::Graph.new(users_relation, [tasks_relation.for_users]) }

  describe '#graph?' do
    it 'returns true' do
      expect(graph.graph?).to be(true)
    end

    it 'returns true when curried' do
      expect(graph.by_name.graph?).to be(true)
    end
  end

  it_behaves_like 'materializable relation' do
    let(:mapper) do
      T(:combine, [[:tasks, name: :name]])
    end

    let(:relation) do
      ROM::Relation::Graph.new(users_relation.by_name('Jane'), [tasks_relation.for_users]) >> mapper
    end
  end

  describe '#method_missing' do
    it 'responds to the root methods' do
      expect(graph).to respond_to(:by_name)
    end

    it 'forwards methods to the root and decorates response' do
      expect(graph.by_name('Jane')).to be_instance_of(ROM::Relation::Graph)
    end

    it 'forwards methods to the root and decorates curried response' do
      expect((users_relation.combine(tasks_relation.for_users)).by_name).to be_instance_of(ROM::Relation::Graph)
    end

    it 'returns original response from the root' do
      expect(graph.mappers).to eql(users_relation.mappers)
    end

    it 'raises method error' do
      expect { graph.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe '#with_nodes' do
    it 'returns a new graph with new nodes' do
      new_tasks = tasks_relation.by_title('foo')
      new_graph = graph.with_nodes([new_tasks])

      expect(new_graph.nodes[0]).to be(new_tasks)
    end
  end

  describe '#call' do
    it 'materializes relations' do
      root, nodes = graph.call.to_a

      expect(root.to_a).to eql(users_relation.to_a)
      expect(nodes.flatten).to eql(tasks_relation.to_a)
    end
  end

  describe '#to_a' do
    it 'coerces to an array' do
      root, nodes = graph.to_a

      expect(root.to_a).to eql(users_relation.to_a)
      expect(nodes.flatten).to eql(tasks_relation.for_users(users_relation).to_a)
    end

    it 'returns empty arrays when left was empty' do
      graph = ROM::Relation::Graph.new(users_relation.by_name('Not here'), [tasks_relation.for_users])

      root, nodes = graph.to_a

      expect(root).to be_empty
      expect(nodes.flatten).to be_empty
    end
  end
end
