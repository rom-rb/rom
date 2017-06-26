RSpec.describe ROM::Changeset::Create do
  subject(:repo) do
    Class.new(ROM::Repository) { relations :users }.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  context 'with a hash' do
    let(:changeset) do
      repo.changeset(:users, name: 'Jane')
    end

    it 'has data' do
      expect(changeset.to_h).to eql(name: 'Jane')
    end

    it 'has relation' do
      expect(changeset.relation).to be(repo.users)
    end

    it 'can be commited' do
      expect(changeset.commit.to_h).to eql(id: 1, name: 'Jane')
    end
  end

  context 'with an array' do
    let(:changeset) do
      repo.changeset(:users, data)
    end

    let(:data) do
      [{ name: 'Jane' }, { name: 'Joe' }]
    end

    it 'has data' do
      expect(changeset.to_a).to eql(data)
    end

    it 'has relation' do
      expect(changeset.relation).to be(repo.users)
    end

    it 'can be commited' do
      expect(changeset.commit.map(&:to_h)).to eql([{ id: 1, name: 'Jane' }, { id: 2, name: 'Joe' }])
    end
  end
end
