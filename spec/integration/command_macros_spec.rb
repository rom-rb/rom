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
      commands :create, update: :by_id, delete: :by_id
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update(user.id, name: 'Jane Doe')

    user = repo.users.by_id(user.id).one

    expect(user.name).to eql('Jane Doe')

    repo.delete(user.id)

    expect(repo.users.by_id(user.id).one).to be(nil)
  end

  it 'allows defining a single command with multiple views' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create, update: [:by_id, :by_name]
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update_by_id(user.id, name: 'Jane Doe')
    user = repo.users.by_id(user.id).one
    expect(user.name).to eql('Jane Doe')

    repo.update_by_name(user.name, name: 'Jane')
    user = repo.users.by_id(user.id).one
    expect(user.name).to eql('Jane')
  end

  it 'uses a mapper built from AST by default' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create
    end.new(rom)

    user = repo.create(name: 'Jane')

    expect(user).to be_kind_of ROM::Struct

    struct_definition = [:users, [:header, [[:attribute, :id], [:attribute, :name]]]]
    expect(user).to be_an_instance_of ROM::Repository::StructBuilder.registry[struct_definition.hash]
  end

  describe 'using custom mappers' do
    before do
      configuration.mappers do
        register :users, name_list: -> users { users.map { |u| u[:name] } }
      end
    end

    it 'allows to use named mapper in commands' do
      repo = Class.new(ROM::Repository[:users]).new(rom)

      name = repo.command(create: :users, mapper: :name_list).call(name: 'Jane')

      expect(name).to eql('Jane')
    end
  end
end
