RSpec.describe ROM::Relation, '#graph' do
  let(:users) do
    ROM::Relation.new([])
  end

  let(:tasks) do
    ROM::Relation.new([])
  end

  let(:posts) do
    ROM::Relation.new([])
  end

  it 'returns a relation graph with one node' do
    expect(users.graph(tasks)).to eql(ROM::Relation::Graph.new(users, [tasks]))
  end

  it 'returns a relation graph with multiple nodes' do
    expect(users.graph(tasks, posts)).to eql(ROM::Relation::Graph.new(users, [tasks, posts]))
  end
end
