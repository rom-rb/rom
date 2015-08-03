RSpec.shared_context 'structs' do
  include_context 'repo'

  let(:user_struct) do
    repo.users.mapper.model
  end

  let(:task_struct) do
    repo.tasks.mapper.model
  end

  let(:tag_struct) do
    repo.tags.mapper.model
  end

  let(:tag_with_task_struct) do
    mapper_for(repo.tag_with_wrapped_task).model
  end

  let(:user_with_tasks_struct) do
    mapper_for(repo.users_with_tasks).model
  end

  let(:user_with_task_struct) do
    mapper_for(repo.users_with_task).model
  end

  let(:task_with_tags_struct) do
    mapper_for(repo.tasks_with_tags).model
  end

  let(:jane) do
    user_struct.new(id: 1, name: 'Jane')
  end

  let(:jane_with_tasks) do
    user_with_tasks_struct.new(id: 1, name: 'Jane', all_tasks: [jane_task])
  end

  let(:jane_with_task) do
    user_with_task_struct.new(id: 1, name: 'Jane', task: jane_task)
  end

  let(:jane_without_task) do
    user_with_task_struct.new(id: 1, name: 'Jane', task: nil)
  end

  let(:jane_task) do
    task_struct.new(id: 2, user_id: 1, title: 'Jane Task')
  end

  let(:task_with_user) do
    task_with_user_struct.new(id: 2, user_id: 1, title: 'Jane Task', owner: jane)
  end

  let(:tag) do
    tag_struct.new(id: 1, task_id: 2, name: 'red')
  end

  let(:task) do
    task_struct.new(id: 2, user_id: 1, title: 'Jane Task')
  end

  let(:tag_with_task) do
    tag_with_task_struct.new(id: 1, task_id: 2, name: 'red', task: task)
  end

  let(:task_with_tag) do
    task_with_tags_struct.new(id: 2, user_id: 1, title: 'Jane Task', tags: [tag])
  end

  let(:user_with_task_and_tags) do
    user_with_tasks_struct.new(id: 1, name: 'Jane', all_tasks: [task_with_tag])
  end

  let(:joe) do
    user_struct.new(id: 2, name: 'Joe')
  end

  let(:joe_with_tasks) do
    user_with_tasks_struct.new(id: 2, name: 'Joe', all_tasks: [joe_task])
  end

  let(:joe_with_task) do
    user_with_task_struct.new(id: 2, name: 'Joe', task: joe_task)
  end

  let(:joe_task) do
    task_struct.new(id: 1, user_id: 2, title: 'Joe Task')
  end
end
