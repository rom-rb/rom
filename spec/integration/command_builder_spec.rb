RSpec.describe 'Building commands' do
  include_context 'database'
  include_context 'relations'
  include_context 'repo'

  describe '#command' do
    it 'builds Create command for a relation' do
      create_user = repo.command(:create, repo.users)

      user = create_user.call(user: { name: 'Jane Doe' })

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane Doe')
    end
  end
end
