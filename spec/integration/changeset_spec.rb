RSpec.describe 'Using changesets' do
  subject(:repo) do
    Class.new(ROM::Repository[:users]) { commands :create }.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  before do
    configuration.commands(:users) do
      define(:create)
    end
  end

  it 'returns a changeset for a given relation' do
    command = repo.command(:create, repo.users)
    changeset = repo.users.changeset(name: "Jane Doe")

    result = command.(changeset)

    expect(result.id).to_not be(nil)
    expect(result.name).to eql("Jane Doe")
  end
end
