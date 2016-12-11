RSpec.describe ROM::Repository, '#transaction' do
  subject(:repo) do
    Class.new(ROM::Repository) { relations :users, :tasks }.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  describe 'creating a user' do
    let(:user_changeset) do
      repo.changeset(:users, name: 'Jane')
    end

    it 'saves data in a transaction' do
      result = repo.transaction do |t|
        t.create(user_changeset)
      end

      expect(result.first.to_h).to eql(id: 1, name: 'Jane')
    end
  end
end
