RSpec.describe ROM::Repository, '#changeset' do
  subject(:repo) do
    Class.new(ROM::Repository) { relations :users }.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  describe ROM::Changeset::Create do
    let(:changeset) do
      repo.changeset(:users, name: 'Jane')
    end

    it 'has data' do
      expect(changeset.to_h).to eql(name: 'Jane')
    end

    it 'has relation' do
      expect(changeset.relation).to be(repo.users)
    end

    it 'can return a dedicated command' do
      expect(changeset.command.call).to eql(id: 1, name: 'Jane')
    end
  end

  describe ROM::Changeset::Update do
    let(:changeset) do
      repo.changeset(:users, user[:id], name: 'Jane Doe')
    end

    let(:user) do
      repo.command(:create, repo.users).call(name: 'Jane')
    end

    it 'has data' do
      expect(changeset.to_h).to eql(name: 'Jane Doe')
    end

    it 'has diff' do
      expect(changeset.diff).to eql(name: 'Jane Doe')
    end

    it 'has relation' do
      expect(changeset.relation).to be(repo.users)
    end

    it 'can return a dedicated command' do
      expect(changeset.command.call).to eql(id: 1, name: 'Jane Doe')
    end
  end

  describe ROM::Changeset::Delete do
    let(:changeset) do
      repo.changeset(delete: relation)
    end

    let(:relation) do
      repo.users.by_pk(user[:id])
    end

    let(:user) do
      repo.command(:create, repo.users).call(name: 'Jane')
    end

    it 'has relation' do
      expect(changeset.relation).to eql(relation)
    end

    it 'can return a dedicated command' do
      expect(changeset.command.call.to_h).to eql(id: 1, name: 'Jane')
      expect(relation.one).to be(nil)
    end
  end

  describe 'custom changeset class' do
    let(:changeset) do
      repo.changeset(changeset_class[:users]).with(data: {})
    end

    let(:changeset_class) do
      Class.new(ROM::Changeset::Create) do
        def to_h
          data.merge(name: 'Jane')
        end
      end
    end

    it 'has data' do
      expect(changeset.to_h).to eql(name: 'Jane')
    end

    it 'has relation' do
      expect(changeset.relation).to be(repo.users)
    end

    it 'can return a dedicated command' do
      expect(changeset.command.call).to eql(id: 1, name: 'Jane')
    end
  end
end
