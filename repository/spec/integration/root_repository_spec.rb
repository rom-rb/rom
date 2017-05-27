RSpec.describe ROM::Repository::Root do
  subject(:repo) do
    Class.new(ROM::Repository[:users]) do
      relations :tasks, :posts, :labels
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

      expect(klass.relations).to eql([:users, :tasks, :posts, :labels])
      expect(klass.root).to be(:users)
    end

    it 'creates base root class' do
      klass = Class.new(ROM::Repository)[:users]

      expect(klass.relations).to eql([:users])
      expect(klass.root).to be(:users)
    end
  end

  describe '#root' do
    it 'returns configured root relation' do
      expect(repo.root.relation).to be(rom.relations[:users])
    end
  end

  describe '#changeset' do
    it 'returns a changeset automatically set for root relation' do
      klass = Class.new(ROM::Changeset::Create)

      changeset = repo.changeset(klass)

      expect(changeset.relation).to be(repo.users)
      expect(changeset).to be_kind_of(klass)
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

    context 'with associations' do
      it 'builds an aggregate from a canonical association' do
        user = repo.aggregate(:labels).where(name: 'Joe').one

        expect(user.name).to eql('Joe')
        expect(user.labels.size).to be(1)
        expect(user.labels[0].name).to eql('green')
      end

      it 'builds an aggregate with nesting level = 2' do
        user = repo.aggregate(posts: [:labels, :author]).where(name: 'Joe').one

        expect(user.name).to eql('Joe')
        expect(user.posts.size).to be(1)
        expect(user.posts[0].title).to eql('Hello From Joe')
        expect(user.posts[0].labels.size).to be(1)
      end

      it 'builds a command from an aggregate' do
        command = repo.command(:create, repo.aggregate(:posts))

        result = command.call(name: 'Jade', posts: [{ title: 'Jade post' }])

        expect(result.name).to eql('Jade')
        expect(result.posts.size).to be(1)
        expect(result.posts[0].title).to eql('Jade post')
      end

      it 'builds same relation as manual combine' do
        left = repo.aggregate(:posts)
        right = repo.users.combine_children(many: repo.posts)

        expect(left.to_ast).to eql(right.to_ast)
      end
    end
  end
end
