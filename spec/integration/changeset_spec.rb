RSpec.describe 'Using changesets' do
  include_context 'database'
  include_context 'relations'

  before do
    module Test
      class User < Dry::Struct
        attribute :id, Dry::Types['strict.int']
        attribute :name, Dry::Types['strict.string']
      end
    end

    configuration.mappers do
      define(:users) do
        model Test::User
        register_as :user
      end
    end
  end

  describe 'Create' do
    subject(:repo) do
      Class.new(ROM::Repository[:users]) {
        relations :books, :posts
        commands :create, update: :by_pk
      }.new(rom)
    end

    let(:custom_changeset) do
      Class.new(ROM::Changeset::Create)
    end

    it 'can be passed to a command' do
      changeset = repo.changeset(name: "Jane Doe")
      command = repo.command(:create, repo.users)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.name).to eql("Jane Doe")
    end

    it 'can be passed to a command graph' do
      changeset = repo.changeset(
        name: "Jane Doe", posts: [{ title: "Just Do It", alien: "or sutin" }]
      )

      command = repo.command(:create, repo.aggregate(:posts))
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.name).to eql("Jane Doe")
      expect(result.posts.size).to be(1)
      expect(result.posts[0].title).to eql("Just Do It")
    end

    it 'preprocesses data using changeset pipes' do
      changeset = repo.changeset(:books, title: "rom-rb is awesome").map(:add_timestamps)
      command = repo.command(:create, repo.books)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
      expect(result.updated_at).to be_instance_of(Time)
    end

    it 'preprocesses data using custom block' do
      changeset = repo.
                    changeset(:books, title: "rom-rb is awesome").
                    map { |tuple| tuple.merge(created_at: Time.now) }

      command = repo.command(:create, repo.books)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
    end

    it 'preprocesses data using built-in steps and custom block' do
      changeset = repo.
                    changeset(:books, title: "rom-rb is awesome").
                    map(:touch) { |tuple| tuple.merge(created_at: Time.now) }

      command = repo.command(:create, repo.books)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
      expect(result.updated_at).to be_instance_of(Time)
    end

    it 'preserves relation mappers' do
      changeset = repo.
                    changeset(custom_changeset).
                    new(repo.users.relation.as(:user)).
                    data(name: 'Joe Dane')

      expect(changeset.commit).to eql(Test::User.new(id: 1, name: 'Joe Dane'))
    end
  end

  describe 'Update' do
    subject(:repo) do
      Class.new(ROM::Repository[:books]) {
        commands :create, update: :by_pk
      }.new(rom)
    end

    it 'can be passed to a command' do
      book = repo.create(title: 'rom-rb is awesome')

      changeset = repo
        .changeset(book.id, title: 'rom-rb is awesome for real')
        .map(:touch)

      expect(changeset.diff).to eql(title: 'rom-rb is awesome for real')

      result = repo.update(book.id, changeset)

      expect(result.id).to be(book.id)
      expect(result.title).to eql('rom-rb is awesome for real')
      expect(result.updated_at).to be_instance_of(Time)
    end

    it 'skips update execution with no diff' do
      book = repo.create(title: 'rom-rb is awesome')

      changeset = repo
        .changeset(book.id, title: 'rom-rb is awesome')

      expect(changeset).to_not be_diff

      result = repo.update(book.id, changeset)

      expect(result.id).to be(book.id)
      expect(result.title).to eql('rom-rb is awesome')
      expect(result.updated_at).to be(nil)
    end
  end
end
