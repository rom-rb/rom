# frozen_string_literal: true

require 'rom-changeset'

RSpec.describe ROM::Repository, '#session' do
  subject(:repo) do
    Class.new(ROM::Repository).new(rom)
  end

  include_context 'database'
  include_context 'relations'

  describe 'with :create command' do
    let(:user_changeset) do
      users.changeset(:create, name: 'Jane')
    end

    it 'saves data in a transaction' do
      repo.session do |s|
        s.add(user_changeset)
      end

      user = repo.users.where(name: 'Jane').one
      expect(user.to_h).to eql(id: 1, name: 'Jane')
    end
  end

  describe 'with :update command' do
    let(:user_changeset) do
      users.by_pk(user.id).changeset(:update, user.to_h.merge(name: 'Jane Doe'))
    end

    let(:user) do
      repo.users.where(name: 'Jane').one
    end

    before do
      repo.users.command(:create).call(name: 'John')
      repo.users.command(:create).call(name: 'Jane')
    end

    it 'saves data in a transaction' do
      repo.session do |s|
        s.add(user_changeset)
      end

      updated_user = repo.users.fetch(user.id)

      expect(updated_user.to_h).to eql(id: 2, name: 'Jane Doe')
    end
  end

  describe 'with :delete command' do
    let(:user) do
      repo.users.where(name: 'Jane').one
    end

    before do
      repo.users.command(:create).call(name: 'John')
      repo.users.command(:create).call(name: 'Jane')
    end

    let(:user_changeset) do
      users.by_pk(user.id).changeset(:delete)
    end

    it 'saves data in a transaction' do
      repo.session do |t|
        t.add(user_changeset)
      end

      expect(repo.users.by_pk(user.id).one).to be(nil)
      expect(repo.users.count).to be(1)
    end
  end

  describe 'with :custom command', :postgres do
    before do
      configuration.commands(:users) do
        define(:create) do
          register_as :custom
        end
      end
    end

    let(:user_changeset) do
      users.changeset(:create, name: 'John').with(command_type: :custom)
    end

    it 'saves data in a transaction' do
      repo.session do |t|
        t.add(user_changeset)
      end

      user = repo.users.first

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('John')
      expect(repo.users.count).to be(1)
    end
  end

  describe 'creating a user with its posts' do
    let(:posts_changeset) do
      posts.changeset(:create, [{ title: 'Post 1' }, { title: 'Post 2' }])
    end

    let(:user_changeset) do
      users.changeset(:create, name: 'Jane')
    end

    it 'saves data in a transaction' do
      repo.session do |s|
        s.add(user_changeset.associate(posts_changeset, :author))
      end

      user = repo.users.combine(:posts).one

      expect(user.name).to eql('Jane')
      expect(user.posts.size).to be(2)
      expect(user.posts[0].title).to eql('Post 1')
      expect(user.posts[1].title).to eql('Post 2')
    end
  end

  describe 'creating a user with its posts and their labels' do
    let(:posts_data) do
      { title: 'Post 1' }
    end

    let(:posts_changeset) do
      posts
        .changeset(:create, posts_data)
        .associate(labels_changeset, :posts)
    end

    let(:labels_changeset) do
      labels.changeset(:create, [{ name: 'red' }, { name: 'green' }])
    end

    let(:user_changeset) do
      users
        .changeset(:create, name: 'Jane')
        .associate(posts_changeset, :author)
    end

    it 'saves data in a transaction' do
      repo.session do |t|
        t.add(user_changeset)
      end

      user = repo.users.combine(posts: [:labels]).one

      expect(user.name).to eql('Jane')
      expect(user.posts.size).to be(1)
      expect(user.posts[0].title).to eql('Post 1')
      expect(user.posts[0].labels.size).to be(2)
      expect(user.posts[0].labels[0].name).to eql('red')
      expect(user.posts[0].labels[1].name).to eql('green')
    end

    context 'with invalid data' do
      let(:posts_data) do
        [{ title: nil }]
      end

      it 'rolls back the transaction' do
        expect {
          repo.session do |t|
            t.add(user_changeset)
          end
        }.to raise_error(ROM::SQL::ConstraintError)

        expect(repo.users.count).to be(0)
        expect(repo.posts.count).to be(0)
        expect(repo.labels.count).to be(0)
      end
    end
  end

  describe 'creating new posts for existing user' do
    let(:posts_changeset) do
      posts
        .changeset(:create, [{ title: 'Post 1' }, { title: 'Post 2' }])
        .associate(user, :author)
    end

    let(:user) do
      repo.users.command(:create).call(name: 'Jane')
    end

    it 'saves data in a transaction' do
      repo.session do |s|
        s.add(posts_changeset)
      end

      user = repo.users.combine(:posts).one

      expect(user.posts.size).to be(2)
      expect(user.posts[0].title).to eql('Post 1')
      expect(user.posts[1].title).to eql('Post 2')
    end
  end

  describe 'nesting sessions' do
    let(:user_changeset) do
      users.changeset(:create, name: 'Jane')
    end

    let(:posts_changeset) do
      posts.changeset(:create, post_data)
    end

    let(:user) do
      repo.users.where(name: 'Jane').one
    end

    context 'when data is valid' do
      let(:post_data) do
        [{ title: 'Post 1' }, { title: 'Post 2' }]
      end

      it 'saves data in transactions' do
        repo.send(:transaction) do |t|
          repo.session { |s| s.add(user_changeset) }
          repo.session { |s| s.add(posts_changeset.associate(user, :author)) }
        end

        user = repo.users.combine(:posts).one

        expect(user.posts.size).to be(2)
        expect(user.posts[0].title).to eql('Post 1')
        expect(user.posts[1].title).to eql('Post 2')
      end
    end

    context 'when data is not valid' do
      let(:post_data) do
        [{ title: 'Post 1' }, { title: nil }]
      end

      it 'rolls back transaction' do
        expect {
          repo.send(:transaction) do |t|
            repo.session { |s| s.add(user_changeset) }
            repo.session { |s| s.add(posts_changeset.associate(user, :author)) }
          end
        }.to raise_error(ROM::SQL::ConstraintError, /title/)

        expect(repo.users.count).to be(0)
        expect(repo.posts.count).to be(0)
      end
    end
  end
end
