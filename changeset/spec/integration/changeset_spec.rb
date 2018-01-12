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
    let(:create_changeset) do
      Class.new(ROM::Changeset::Create)
    end

    it 'sets empty data only for stateful changesets' do
      create = users.changeset(:create)
      expect(create).to be_empty
      expect(create).to be_kind_of(ROM::Changeset::Create)

      update = users.changeset(:update)
      expect(update).to be_empty
      expect(update).to be_kind_of(ROM::Changeset::Update)

      delete = users.changeset(:delete)
      expect(delete).to be_kind_of(ROM::Changeset::Delete)
    end

    it 'works with command plugins' do
      configuration.commands(:books) do
        define(:create) do
          use :timestamps
          timestamp :created_at, :updated_at
          result :one
        end
      end

      changeset = books.changeset(:create, title: "rom-rb is awesome")

      result = changeset.commit

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
      expect(result.updated_at).to be_instance_of(Time)
    end

    it 'can be passed to a command' do
      changeset = users.changeset(:create, name: "Jane Doe")
      command = users.command(:create)

      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.name).to eql("Jane Doe")
    end

    it 'can be passed to a command graph' do
      changeset = users.changeset(
        :create,
        name: "Jane Doe", posts: [{ title: "Just Do It", alien: "or sutin" }]
      )

      command = users.combine(:posts).command(:create)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.name).to eql("Jane Doe")
      expect(result.posts.size).to be(1)
      expect(result.posts[0].title).to eql("Just Do It")
    end

    it 'preprocesses data using changeset pipes' do
      changeset = books.changeset(:create, title: "rom-rb is awesome").map(:add_timestamps)
      command = books.command(:create)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
      expect(result.updated_at).to be_instance_of(Time)
    end

    it 'preprocesses data using custom block' do
      changeset = books.
                    changeset(:create, title: "rom-rb is awesome").
                    map { |tuple| tuple.merge(created_at: Time.now) }

      command = books.command(:create)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
    end

    it 'preprocesses data using built-in steps and custom block' do
      changeset = books.
                    changeset(:create, title: "rom-rb is awesome").
                    extend(:touch) { |tuple| tuple.merge(created_at: Time.now) }

      command = books.command(:create)
      result = command.(changeset)

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome")
      expect(result.created_at).to be_instance_of(Time)
      expect(result.updated_at).to be_instance_of(Time)
    end

    it 'preserves relation mappers with create' do
      changeset = users.map_with(:user).changeset(:create, name: 'Joe Dane')

      expect(changeset.commit.to_h).to eql(id: 1, name: 'Joe Dane')
    end
  end

  describe 'Update' do
    it 'can be passed to a command' do
      book = books.command(:create).call(title: 'rom-rb is awesome')

      changeset = books.by_pk(book.id).
                    changeset(:update, title: 'rom-rb is awesome for real').
                    extend(:touch)

      expect(changeset.diff).to eql(title: 'rom-rb is awesome for real')

      result = changeset.commit

      expect(result.id).to be(book.id)
      expect(result.title).to eql('rom-rb is awesome for real')
      expect(result.updated_at).to be_instance_of(Time)
    end


    it 'works with command plugins' do
      configuration.commands(:books) do
        define(:update) do
          use :timestamps
          timestamp :updated_at
          result :one
        end
      end

      book = books.command(:create).call(title: 'rom-rb is awesome')

      changeset = books.by_pk(book.id).changeset(:update, title: "rom-rb is awesome for real")

      result = changeset.commit

      expect(result.id).to_not be(nil)
      expect(result.title).to eql("rom-rb is awesome for real")
      expect(result.updated_at).to be_instance_of(Time)
    end


    it 'skips update execution with no diff' do
      book = books.command(:create).call(title: 'rom-rb is awesome')

      changeset = books.
                    by_pk(book.id).
                    changeset(:update, title: 'rom-rb is awesome').
                    extend(:touch)

      expect(changeset).to_not be_diff

      result = changeset.commit

      expect(result.id).to be(book.id)
      expect(result.title).to eql('rom-rb is awesome')
      expect(result.updated_at).to be(nil)
    end
  end
end
