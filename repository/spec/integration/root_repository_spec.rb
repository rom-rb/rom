RSpec.describe ROM::Repository::Root do
  subject(:repo) do
    klass.new(rom)
  end

  let(:klass) do
    Class.new(ROM::Repository[:users])
  end

  include_context 'database'
  include_context 'relations'

  describe '.[]' do
    it 'creates a pre-configured root repo class' do
      klass = ROM::Repository[:users]

      expect(klass.root).to be(:users)

      child = klass[:users]

      expect(child.root).to be(:users)
      expect(child < klass).to be(true)
    end
  end

  describe 'inheritance' do
    it 'inherits root and relations' do
      klass = Class.new(repo.class)

      expect(klass.root).to be(:users)
    end

    it 'creates base root class' do
      klass = Class.new(ROM::Repository)[:users]

      expect(klass.root).to be(:users)
    end
  end

  describe 'overriding reader' do
    it 'works with super' do
      klass.class_eval do
        def users
          super.limit(10)
        end
      end

      expect(repo.users.dataset.opts[:limit]).to be(10)
    end

    it 'works with aggregate' do
      klass.class_eval do
        def users
          aggregate(:tasks)
        end
      end

      expect(repo.users).to be_graph
    end
  end

  describe '#root' do
    it 'returns configured root relation' do
      expect(repo.root.dataset).to be(rom.relations[:users].dataset)
    end
  end

  describe '#aggregate' do
    include_context 'seeds'

    it 'builds an aggregate from the root relation and other relation(s)' do
      user = repo.aggregate(:tasks).where(name: 'Jane').one

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

      it 'builds same relation as manual combine' do
        left = repo.aggregate(:posts)
        right = repo.users.combine(:posts)

        expect(left.to_ast).to eql(right.to_ast)
      end
    end
  end
end
