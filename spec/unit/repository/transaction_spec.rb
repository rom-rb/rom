RSpec.describe ROM::Repository, '#transaction' do
  let(:user_repo) do
    Class.new(ROM::Repository[:users]) { commands :create }.new(rom)
  end

  let(:task_repo) do
    Class.new(ROM::Repository[:tasks]) { commands :create, :update }.new(rom)
  end

  include_context 'database'
  include_context 'relations'

  it 'creating user with tasks' do
    user, task = user_repo.transaction do
      user_changeset = user_repo.changeset(name: 'Jane')
      task_changeset = task_repo.changeset(title: 'Task One')

      user = user_repo.create(user_changeset)
      task = task_repo.create(task_changeset.associate(user, :user))

      [user, task]
    end

    expect(user.name).to eql('Jane')
    expect(task.user_id).to be(user.id)
    expect(task.title).to eql('Task One')
  end

  it 'updating tasks user' do
    jane = user_repo.create(name: 'Jane')
    john = user_repo.create(name: 'John')
    task = task_repo.create(title: 'Jane Task', user_id: jane.id)

    task = task_repo.transaction do
      task_changeset = task_repo.changeset(task.id, title: 'John Task').associate(john, :user).commit
      task_repo.update(task_changeset)
    end

    expect(task.user_id).to be(john.id)
    expect(task.title).to eql('John Task')
  end
end
