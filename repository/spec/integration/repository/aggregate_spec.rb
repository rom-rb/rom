RSpec.describe ROM::Repository::Root, '#aggregate' do
  subject(:repo) do
    Class.new(ROM::Repository[:users]) do
      relations :tasks, :posts, :labels
    end.new(rom)
  end

  include_context 'database'
  include_context 'relations'
  include_context 'seeds'

  it 'loads a graph with aliased children and its parents' do
    user = repo.aggregate(aliased_posts: :author).first

    expect(user.aliased_posts.count).to be(1)
    expect(user.aliased_posts[0].author.id).to be(user.id)
    expect(user.aliased_posts[0].author.name).to eql(user.name)
  end


  it 'exposes nodes via `node` method' do
    jane = repo.
             aggregate(:posts).
             node(:posts) { |posts| posts.where(title: 'Another one') }.
             where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts).to be_empty

    repo.posts.insert author_id: 1, title: 'Another one'

    jane = repo.
             aggregate(:posts).
             node(:posts) { |posts| posts.where(title: 'Another one') }.
             where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].title).to eql('Another one')
  end

  it 'exposes nested nodes via `node` method' do
    jane = repo.
             aggregate(posts: :labels).
             node(posts: :labels) { |labels| labels.where(name: 'red') }.
             where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].labels.size).to be(1)
    expect(jane.posts[0].labels[0].name).to eql('red')
  end

  it 'raises arg error when invalid relation name was passed to `node` method' do
    expect { repo.aggregate(:posts).node(:poztz) {} }.
      to raise_error(ArgumentError, ':poztz is not a valid aggregate node name')
  end
end
