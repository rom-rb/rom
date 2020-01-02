require 'rom-changeset'

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

  it 'allows configuring an update command' do
    repo = Class.new(ROM::Repository[:users]) do
      commands update: :by_pk
    end.new(rom)

    user_id = users.insert(name: 'Jane')

    repo.update(user_id, name: 'Jane Doe')

    user = repo.users.by_pk(user_id).one

    expect(user.name).to eql('Jane Doe')

    repo.update(user_id, users.changeset(:update, name: 'Jade'))

    user = repo.users.by_pk(user_id).one

    expect(user.name).to eql('Jade')
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

    repo.users.insert(name: 'Jade')

    user = repo.update('Jade', name: 'Jade Doe')
    expect(user.name).to eql('Jade Doe')

    expect(repo.update('Oops', name: 'Jade')).to be(nil)
  end

  it 'allows to configure update command without create one' do
    repo = Class.new(ROM::Repository[:users]) do
      commands update: :by_pk
    end.new(rom)

    user_id = users.insert(name: 'Jane')

    repo.update(user_id, name: 'Jane Doe')

    updated_user = repo.users.by_pk(user_id).one

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

    struct_definition = [:users, [repo.users.schema[:id].to_read_ast,
                                  repo.users.schema[:name].to_read_ast]]

    expect(user).to be_an_instance_of repo.users.mappers.compiler.struct_compiler[*struct_definition, ROM::Struct]
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

    it 'allows to pass options to plugins' do
      repo = Class.new(ROM::Repository[:users]) do
        commands :create, update: :by_pk, use: %i[modify_name timestamps], plugins_options: { modify_name: { reverse: true } }
      end.new(rom)

      user = repo.create(name: 'Jane')
      expect(user.name).to eq 'enaJ'
    end

    it 'allows to use several plugins' do
      repo = Class.new(ROM::Repository[:users]) do
        commands :create, use: %i[upcase_name timestamps]
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

      name = repo.users.command(:create, mapper: :name_list).call(name: 'Jane')

      expect(name).to eql('Jane')
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

    it 'allows to set update macro with Date as arg' do
      repo = Class.new(ROM::Repository[:books]) do
        commands delete: :expired
      end.new(rom)

      repo.books.insert(title: 'John Doe', created_at: Time.now - 3600)

      pending 'views with default args are not supported yet'

      repo.delete(Time.now)

      expect(repo.books.count).to be_zero
    end

    it 'allows to set update macro with multiple args' do
      repo = Class.new(ROM::Repository[:books]) do
        commands delete: [:by_author_id_and_title]
      end.new(rom)

      author_id = repo.users.insert(name: 'Jane Doe')
      repo.books.insert(title: 'Hello World', author_id: author_id)

      repo.delete(author_id, 'Hello World')

      expect(repo.books.count).to be_zero
    end
  end
end
