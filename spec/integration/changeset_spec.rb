RSpec.describe 'Using changesets' do
  subject(:repo) do
    Class.new(ROM::Repository[:users]) { relations :books; commands :create }.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  before do
    configuration.commands(:users) do
      define(:create)
    end
  end

  it 'returns a changeset for a given relation' do
    changeset = repo.users.changeset(name: "Jane Doe")
    command = repo.command(:create, repo.users)
    result = command.(changeset)

    expect(result.id).to_not be(nil)
    expect(result.name).to eql("Jane Doe")
  end

  it 'data pipe' do
    changeset = repo.books.changeset(title: "rom-rb is awesome").map(:add_timestamps)
    command = repo.command(:create, repo.books)
    result = command.(changeset)

    expect(result.id).to_not be(nil)
    expect(result.title).to eql("rom-rb is awesome")
    expect(result.created_at).to be_instance_of(Time)
    expect(result.updated_at).to be_instance_of(Time)
  end
end
