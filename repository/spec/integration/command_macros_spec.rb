RSpec.describe ROM::Repository, '.command' do
  include_context 'database'
  include_context 'relations'

  it 'allows configuring a create command' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create
    end.new(rom)

    user = repo.create(name: 'Jane')

    expect(user.id).to_not be(nil)
    expect(user.name).to eql('Jane')
  end

  it 'allows configuring an update and delete commands' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create, update: :by_pk, delete: :by_pk
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update(user.id, name: 'Jane Doe')

    user = repo.users.by_pk(user.id).one

    expect(user.name).to eql('Jane Doe')

    repo.delete(user.id)

    expect(repo.users.by_pk(user.id).one).to be(nil)
  end

  it 'configures an update command with custom restriction' do
    repo = Class.new(ROM::Repository[:users]) do
      commands update: :by_name
    end.new(rom)

    repo.relations.users.insert(name: 'Jade')

    user = repo.update('Jade', name: 'Jade Doe')
    expect(user.name).to eql('Jade Doe')

    expect(repo.update('Oops', name: 'Jade')).to be(nil)
  end

  it 'allows to configure update command without create one' do
    repo = Class.new(ROM::Repository[:users]) do
      commands update: :by_pk
    end.new(rom)

    user = repo.command(create: :users)[name: 'Jane']

    repo.update(user.id, name: 'Jane Doe')

    updated_user = repo.users.by_pk(user.id).one

    expect(updated_user.name).to eql('Jane Doe')
  end

  it 'allows to configure :delete command without args' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :delete
    end.new(rom)

    repo.users.insert(name: 'Jane')
    repo.users.insert(name: 'John')

    repo.delete

    expect(repo.users.count).to be_zero
  end

  it 'allows defining a single command with multiple views' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create, update: [:by_pk, :by_name]
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update_by_pk(user.id, name: 'Jane Doe')
    user = repo.users.by_pk(user.id).one
    expect(user.name).to eql('Jane Doe')

    repo.update_by_name(user.name, name: 'Jane')
    user = repo.users.by_pk(user.id).one
    expect(user.name).to eql('Jane')
  end

  it 'uses a mapper built from AST by default' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create
    end.new(rom)

    user = repo.create(name: 'Jane')

    expect(user).to be_kind_of Dry::Struct

    struct_definition = [:users, [:header, [
                                    [:attribute, repo.users.schema[:id]],
                                    [:attribute, repo.users.schema[:name]]]]]

    expect(user).to be_an_instance_of ROM::Repository::StructBuilder.cache[struct_definition.hash]
  end

  describe 'using plugins' do
    include_context 'plugins'

    before do
      conn.alter_table :users do
        add_column :created_at, :timestamp, null: false
        add_column :updated_at, :timestamp, null: false
      end
    end

    it 'allows to use plugins in generated commands' do
      repo = Class.new(ROM::Repository[:users]) do
        commands :create, update: :by_pk, use: :timestamps
      end.new(rom)

      user = repo.create(name: 'Jane')
      expect(user.created_at).to be_within(1).of Time.now
      expect(user.created_at).to eql(user.updated_at)

      repo.update(user.id, **user, name: 'Jane Doe')
      updated_user = repo.users.by_pk(user.id).one
      expect(updated_user.created_at).to eql(user.created_at)
      expect(updated_user.updated_at).to be > updated_user.created_at
    end

    it 'allows to use several plugins' do
      repo = Class.new(ROM::Repository[:users]) do
        commands :create, use: %i(upcase_name timestamps)
      end.new(rom)

      user = repo.create(name: 'Jane')
      expect(user.created_at).to be_within(1).of Time.now
      expect(user.name).to eql('JANE')
    end
  end

  describe 'using custom mappers' do
    before do
      configuration.mappers do
        register :users,
                 name_list: -> users { users.map { |u| u[:name] } },
                 id_list: -> users { users.map { |u| u[:id] } }
      end
    end

    it 'allows to use named mapper in commands' do
      repo = Class.new(ROM::Repository[:users]).new(rom)

      name = repo.command(create: :users, mapper: :name_list).call(name: 'Jane')

      expect(name).to eql('Jane')
    end

    it 'caches command pipeline using mapper option' do
      repo = Class.new(ROM::Repository[:users]).new(rom)

      c1 = repo.command(create: :users, mapper: :name_list)
      c2 = repo.command(create: :users, mapper: :name_list)
      c3 = repo.command(create: :users, mapper: :id_list)

      name = c1.call(name: 'Jane')
      id = c3.call(name: 'John')

      expect(c1).to be c2
      expect(c3).not_to be c1

      expect(name).to eql('Jane')
      expect(id).to eql(2)
    end

    it 'allows to set a mapper with a class-level macro' do
      repo = Class.new(ROM::Repository[:users]) do
        commands :create, update: :by_pk, delete: :by_pk, mapper: :name_list
      end.new(rom)

      name = repo.create(name: 'Jane')
      expect(name).to eql('Jane')

      updated_name = repo.update(1, name: 'Jane Doe')
      expect(updated_name).to eql('Jane Doe')

      deleted_name = repo.delete(1)
      expect(deleted_name).to eql('Jane Doe')
    end
  end
end
