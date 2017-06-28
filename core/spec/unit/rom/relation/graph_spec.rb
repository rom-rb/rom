RSpec.describe ROM::Relation::Graph do
  include_context 'gateway only'
  include_context 'users and tasks'

  def t(*args)
    ROM::Processor::Transproc::Functions[*args]
  end

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      auto_map false

      def by_name(name)
        restrict(name: name)
      end
    end.new(users_dataset)
  end

  let(:tasks_relation) do
    Class.new(ROM::Memory::Relation) do
      auto_map false

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
      t(:combine, [[:tasks, name: :name]])
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
      expect((users_relation.graph(tasks_relation.for_users)).by_name).to be_instance_of(ROM::Relation::Graph)
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
      expect(graph.call).to match_array([
        users_relation.to_a,
        [tasks_relation.to_a]
      ])
    end
  end

  describe '#to_a' do
    it 'coerces to an array' do
      expect(graph).to match_array([
        users_relation.to_a,
        [tasks_relation.for_users(users_relation).to_a]
      ])
    end

    it 'returns empty arrays when left was empty' do
      graph = ROM::Relation::Graph.new(users_relation.by_name('Not here'), [tasks_relation.for_users])

      expect(graph).to match_array([
        [], [ROM::Relation::Loaded.new(tasks_relation.for_users, []).to_a]
      ])
    end
  end
end
