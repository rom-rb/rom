# frozen_string_literal: true

RSpec.shared_context 'changeset / structs' do
  let(:user_struct) do
    repo.users.mapper.model
  end

  let(:task_struct) do
    repo.tasks.mapper.model
  end

  let(:tag_struct) do
    repo.tags.mapper.model
  end

  let(:post_struct) do
    repo.posts.mapper.model
  end

  let(:label_struct) do
    repo.labels.mapper.model
  end

  let(:post_with_labels_struct) do
    mapper_for(repo.posts_with_labels).model
  end

  let(:label_with_posts_struct) do
    mapper_for(repo.label_with_posts).model
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

  let(:user_with_posts_struct) do
    mapper_for(repo.users_with_posts_and_their_labels).model
  end

  let(:task_with_tags_struct) do
    mapper_for(repo.tasks_with_tags).model
  end

  let(:task_with_user_struct) do
    mapper_for(repo.task_with_user).model
  end

  let(:task_with_owner_struct) do
    mapper_for(repo.task_with_owner).model
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
    task_with_user_struct.new(id: 2, user_id: 1, title: 'Jane Task', user: jane)
  end

  let(:task_with_owner) do
    task_with_owner_struct.new(id: 2, user_id: 1, title: 'Jane Task', owner: jane)
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

  let(:jane_with_posts) do
    user_with_posts_struct.new(id: 1, name: 'Jane', posts: [post_with_label])
  end

  let(:label_red) do
    label_with_posts_struct.new(id: 1, name: 'red', post: 1)
  end

  let(:label_blue) do
    label_with_posts_struct.new(id: 3, name: 'blue', post: 1)
  end

  let(:post_with_label) do
    post_with_labels_struct.new(id: 2, title: 'Hello From Jane',
                                body: 'Jane Post',
                                author_id: 1,
                                labels: [label_red, label_blue])
  end
end
