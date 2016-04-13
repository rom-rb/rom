RSpec.describe ROM::Repository::Root do
  subject(:repo) do
    Class.new(ROM::Repository[:users]) do
      relations :tasks
    end.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  describe '.[]' do
    it 'creates a pre-configured root repo class' do
      klass = ROM::Repository[:users]

      expect(klass.relations).to eql([:users])
      expect(klass.root).to be(:users)

      child = klass[:users]

      expect(child.relations).to eql([:users])
      expect(child.root).to be(:users)
      expect(child < klass).to be(true)
    end
  end

  describe 'inheritance' do
    it 'inherits root and relations' do
      klass = Class.new(repo.class)

      expect(klass.relations).to eql([:users, :tasks])
      expect(klass.root).to be(:users)
    end
  end

  describe '#root' do
    it 'returns configured root relation' do
      expect(repo.root.relation).to be(rom.relations[:users])
    end
  end

  describe '#aggregate' do
    include_context 'seeds'

    it 'builds an aggregate from the root relation and other relation(s)' do
      user = repo.aggregate(many: repo.tasks).where(name: 'Jane').one

      expect(user.name).to eql('Jane')
      expect(user.tasks.size).to be(1)
      expect(user.tasks[0].title).to eql('Jane Task')
    end
  end
end
