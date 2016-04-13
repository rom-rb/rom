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
end
