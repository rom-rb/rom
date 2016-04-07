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
end
