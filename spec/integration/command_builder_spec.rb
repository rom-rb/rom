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

    it 'builds Create command for a relation graph with one-to-one' do
      create_user = repo.command(
        :create,
        repo.users.combine_children(one: repo.tasks)
      )

      user = create_user.call(
        user: { name: 'Jane Doe', task: { title: 'Task one' } }
      ).one

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
        user: { name: 'Jane Doe', task: { title: 'Task one', tags: [{ name: 'red' }] } }
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

      user = create_user.call(
        user: { name: 'Jane Doe', tasks: [{ title: 'Task one' }] }
      ).one

      expect(user.id).to_not be(nil)
      expect(user.name).to eql('Jane Doe')
      expect(user.tasks).to be_instance_of(Array)
      expect(user.tasks.first.title).to eql('Task one')
    end
  end
end
