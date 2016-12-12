RSpec.describe ROM::Repository, '#transaction' do
  subject(:repo) do
    Class.new(ROM::Repository) { relations :users, :posts }.new(rom)
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

      expect(result.to_h).to eql(id: 1, name: 'Jane')
    end
  end

  describe 'creating a user with its posts' do
    let(:posts_changeset) do
      repo.changeset(:posts, [{ title: 'Post 1' }, { title: 'Post 2' }])
    end

    let(:user_changeset) do
      repo.changeset(:users, name: 'Jane')
    end

    it 'saves data in a transaction' do
      repo.transaction do |t|
        t.create(user_changeset).associate(posts_changeset, :author)
      end

      user = repo.users.combine(:posts).one

      expect(user.name).to eql('Jane')
      expect(user.posts.size).to be(2)
      expect(user.posts[0].title).to eql('Post 1')
      expect(user.posts[1].title).to eql('Post 2')
    end
  end
end
