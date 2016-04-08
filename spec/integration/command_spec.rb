RSpec.describe ROM::Repository, '#command' do
  include_context 'database'
  include_context 'relations'
  include_context 'repo'

  context ':create' do
    it 'builds Create command for a relation' do
      create_user = repo.command(create: :users)

      user = create_user.call(name: 'Jane Doe')

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane Doe')
    end

    it 'caches commands' do
      create_user = -> { repo.command(create: :users) }

      expect(create_user.()).to be(create_user.())
    end

    it 'builds Create command for a relation graph with one-to-one' do
      create_user = repo.command(
        :create,
        repo.users.combine_children(one: repo.tasks)
      )

      user = create_user.call(name: 'Jane Doe', task: { title: 'Task one' }).one

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane Doe')
      expect(user.task.title).to eql('Task one')
    end

    it 'builds Create command for a deeply nested relation graph' do
      create_user = repo.command(
        :create,
        repo.users.combine_children(one: repo.tasks.combine_children(many: repo.tags))
      )

      user = create_user.call(
        name: 'Jane Doe', task: { title: 'Task one', tags: [{ name: 'red' }] }
      ).one

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane Doe')
      expect(user.task.title).to eql('Task one')
      expect(user.task.tags).to be_instance_of(Array)
      expect(user.task.tags.first.name).to eql('red')
    end

    it 'builds Create command for a relation graph with one-to-many' do
      create_user = repo.command(
        :create,
        repo.users.combine_children(many: repo.tasks)
      )

      user = create_user.call(name: 'Jane Doe', tasks: [{ title: 'Task one' }]).one

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane Doe')
      expect(user.tasks).to be_instance_of(Array)
      expect(user.tasks.first.title).to eql('Task one')
    end

    it 'builds Create command for a deeply nested graph with one-to-many' do
      create_user = repo.command(
        :create,
        repo.aggregate(many: repo.tasks.combine_children(many: repo.tags))
      )

      user = create_user.call(
        name: 'Jane',
        tasks: [{ title: 'Task', tags: [{ name: 'red' }]}]
      ).one

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane')
      expect(user.tasks).to be_instance_of(Array)
      expect(user.tasks.first.title).to eql('Task')
      expect(user.tasks.first.tags).to be_instance_of(Array)
      expect(user.tasks.first.tags.first.name).to eql('red')
    end
  end

  context ':update' do
    it 'builds Update command for a relation' do
      repo.users.insert(id: 3, name: 'Jane')

      update_user = repo.command(:update, repo.users)

      user = update_user.by_id(3).call(name: 'Jane Doe')

      expect(user.id).to be(3)
      expect(user.name).to eql('Jane Doe')
    end
  end

  context ':delete' do
    it 'builds Delete command for a relation' do
      repo.users.insert(id: 3, name: 'Jane')

      delete_user = repo.command(:delete, repo.users)

      delete_user.by_id(3).call

      expect(repo.users.by_id(3).one).to be(nil)
    end
  end

  it 'raises error when unsupported type is used' do
    expect { repo.command(:oops, repo.users) }.to raise_error(
      ArgumentError, /oops/
    )
  end
end
