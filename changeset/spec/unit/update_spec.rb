RSpec.describe ROM::Changeset::Update do
  subject(:repo) do
    Class.new(ROM::Repository) { relations :users }.new(rom)
  end

  include_context 'database'
  include_context 'relations'


  let(:data) do
    { name: 'Jane Doe' }
  end

  shared_context 'a valid update changeset' do
    let!(:jane) do
      repo.command(:create, repo.users).call(name: 'Jane')
    end

    let!(:joe) do
      repo.command(:create, repo.users).call(name: 'Joe')
    end

    it 'has data' do
      expect(changeset.to_h).to eql(name: 'Jane Doe')
    end

    it 'has diff' do
      expect(changeset.diff).to eql(name: 'Jane Doe')
    end

    it 'has relation' do
      expect(changeset.relation.one).to eql(repo.users.by_pk(jane[:id]).one)
    end

    it 'can be commited' do
      expect(changeset.commit).to eql(id: 1, name: 'Jane Doe')
      expect(repo.users.by_pk(joe[:id]).one).to eql(joe)
    end
  end

  context 'using PK to restrict a relation' do
    let(:changeset) do
      repo.changeset(:users, jane[:id], data)
    end

    include_context 'a valid update changeset'
  end

  context 'using custom relation' do
    let(:changeset) do
      repo.changeset(update: repo.users.by_pk(jane[:id])).data(data)
    end

    include_context 'a valid update changeset'
  end
end
